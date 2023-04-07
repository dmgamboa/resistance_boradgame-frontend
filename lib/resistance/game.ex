defmodule Player do
  defstruct [
    # player id
    :id,
    # player name
    :name,
    # :good | :bad
    :role,
    # bool
    :is_king,
    # bool
    :on_quest
  ]

  def new(id, name, role, is_king \\ false, on_quest \\ false) do
    %Player{id: id, name: name, role: role, is_king: is_king, on_quest: on_quest}
  end
end

defmodule Game.Server do
  use GenServer
  require Logger

  @doc """
  Store game state. The state is a map with the following keys:
      players: [Player], # a list of Player, order never change during the game
      quest_outcomes: [:success | :fail],     # a list of quest outcomes
      stage: :party_assembling | :voting | :quest | :quest_reveal, # current stage of the game
      team_votes: %{player_id => :approve | :reject},      # a map of player's vote for the current team
      quest_votes: %{player_id => :assist | :sabotage}      # a map of player's vote for the current quest
      team_rejection_count: int
  """

  def start_link(pregame_state) do
    GenServer.start_link(__MODULE__, pregame_state, name: __MODULE__)
  end

  @doc """
    get one particular player struct by his/her name
  """
  def get_player_info(player_id) do
    GenServer.call(__MODULE__, {:get_player_info, player_id})
  end

  @doc """
    toggle selected player's on_quest status
  """
  def toggle_quest_member(king_id, player_id) do
    GenServer.call(__MODULE__, {:toggle_quest_member, king_id, player_id})
  end

  @doc """
    add a player's vote to the current vote list. If everyone has voted, broadcast if the team is approved or not
  """
  def vote_for_team(player_id, vote) do
    GenServer.cast(__MODULE__, {:vote_for_team, player_id, vote})
  end

  @doc """
    menbers of the current team vote for the mission. If everyone has voted, broadcast if the mission is successful or not
  """
  def vote_for_mission(player_id, vote) do
    GenServer.cast(__MODULE__, {:vote_for_mission, player_id, vote})
  end

  ### subscribe and broadcast functions
  def subscribe() do
    Phoenix.PubSub.subscribe(Resistance.PubSub, "game")
  end

  @impl true
  def init(pregame_state) do
    id_n_names =
      Enum.reduce(pregame_state, [], fn {player_id, {name, _}}, acc ->
        [{player_id, name} | acc]
      end)

    players = make_players(id_n_names)

    state = %{
      # a list of Player, order never change during the game
      players: players,
      # [:success | :fail]   #current_mission = length(mission_results) + 1
      quest_outcomes: [],
      # :init | :party_assembling | :voting | :quest | :quest_reveal | :end_game
      stage: :init,
      # %{player_id => :approve | :reject}
      team_votes: default_votes(players),
      # %{player_id => :assist | :sabotage}
      quest_votes: %{},
      team_rejection_count: 0
    }

    :timer.send_after(3000, self(), {:end_stage, :init})
    {:ok, state}
  end

  @impl true
  def handle_call({:get_player_info, id}, _from, state) do
    player = Enum.find(state.players, fn player -> player.id == id end)
    {:reply, player, state}
  end

  @impl true
  def handle_call({:toggle_quest_member, king_id, player_id}, _from, state) do
    cond do
      find_king(state.players).id != king_id ->
        {:reply, {:error, "You are not the king"}, state}

      is_team_full(state.players, player_id) ->
        # 3 players already on quest and player_id is not one of them
        {:reply, {:error, "The team is full"}, state}

      true ->
        updated_players =
          Enum.map(state.players, fn player ->
            if player.id == player_id do
              prev_on_quest = player.on_quest
              %Player{player | on_quest: !prev_on_quest}
            else
              player
            end
          end)

        new_state = %{state | players: updated_players}
        broadcast(:update, new_state)
        {:reply, :ok, new_state}
    end
  end

  @impl true
  def handle_cast({:vote_for_team, player_id, vote}, state) do
    updated_team_votes = Map.put(state.team_votes, player_id, vote)
    new_state = %{state | team_votes: updated_team_votes}

    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:vote_for_mission, player_id, vote}, state) do
    updated_quest_votes = Map.put(state.quest_votes, player_id, vote)
    new_state = %{state | quest_votes: updated_quest_votes}

    {:noreply, new_state}
  end

  @impl true
  def handle_info({:end_stage, stage}, state) do
    case stage do
      :init ->
        {:noreply, party_assembling_stage(state)}

      :party_assembling ->
        {:noreply, voting_stage(state)}

      :voting ->
        if check_team_approved(state.team_votes) do
          {:noreply, clean_up(state, true)}
        else
          {:noreply, quest_stage(state)}
        end

      :quest ->
        {:noreply, quest_reveal_stage(state)}

      :quest_reveal ->
        {:noreply, clean_up(state, false)}
    end
  end

  # return a list of players, with 1/3 of them being bad and the rest being good
  defp make_players(ids_n_names) do
    num_bad = (length(ids_n_names) / 3) |> Float.ceil() |> round
    num_good = length(ids_n_names) - num_bad
    roles = Enum.shuffle(List.duplicate(:good, num_good) ++ List.duplicate(:bad, num_bad))

    Enum.zip_with(ids_n_names, roles, fn {id, name}, role ->
      Player.new(id, name, role)
    end)
  end

  defp party_assembling_stage(state) do
    Logger.log(:info, "party_assembling_stage")
    players = assign_next_king(state.players)
    new_state = Map.put(state, :players, players)
    new_king = find_king(new_state.players).name
    broadcast(:message, {:server, "#{new_king} is now king!"})
    broadcast(:update, new_state)
    :timer.send_after(15000, self(), {:end_stage, :party_assembling})
    new_state
  end

  defp voting_stage(state) do
    Logger.log(:info, "voting_stage")
    # randomly select players to be on quest if not enough
    quest_votes = default_quest_votes(state.players)
    num_mem_to_add = 3 - length(Map.keys(quest_votes))

    more_quest_votes =
      state.players
      |> Enum.filter(fn p -> not Map.has_key?(quest_votes, p.id) end)
      |> Enum.take_random(num_mem_to_add)
      |> Enum.map(fn p -> %Player{p | on_quest: true} end)
      |> default_quest_votes()

    quest_votes = Map.merge(quest_votes, more_quest_votes)

    new_state = state |> Map.put(:stage, :voting) |> Map.put(:quest_votes, quest_votes)
    broadcast(:update, new_state)
    :timer.send_after(15000, self(), {:end_stage, :voting})
    new_state
  end

  defp quest_stage(state) do
    Logger.log(:info, "quest_stage")
    new_state = Map.put(state, :stage, :quest)
    broadcast(:update, new_state)
    :timer.send_after(15000, self(), {:end_stage, :quest})
    new_state
  end

  defp quest_reveal_stage(state) do
    Logger.log(:info, "quest_reveal_stage")
    new_state = Map.put(state, :stage, :quest_reveal)
    broadcast(:update, new_state)
    :timer.send_after(15000, self(), {:end_stage, :quest_reveal})
    new_state
  end

  # called when quest team is rejected
  defp clean_up(state, true) do
    Logger.log(:info, "clean_up")
    :timer.send_after(3000, self(), {:end_stage, :init})

    case state.team_rejection_count do
      4 ->
        broadcast(:message, {:server, "Bad guys win!"})
        broadcast(:update, %{state | stage: :end_game})
        state

      _ ->
        %{
          players: Enum.map(state.players, fn player -> %Player{player | on_quest: false} end),
          quest_outcomes: state.quest_outcomes,
          stage: :init,
          team_votes: default_votes(state.players),
          quest_votes: %{},
          team_rejection_count: state.team_rejection_count + 1
        }
    end
  end

  # called when quest reveal stage finished
  defp clean_up(state, _) do
    Logger.log(:info, "clean_up")
    :timer.send_after(3000, self(), {:end_stage, :init})
    quest_result = get_result(state.quest_votes)
    new_quest_outcomes = state.quest_outcomes ++ [quest_result]

    case check_win_condition(new_quest_outcomes) do
      {:end_game, :bad} ->
        broadcast(:message, {:server, "Bad guys win!"})
        broadcast(:update, %{state | stage: :end_game})
        state

      {:end_game, :good} ->
        broadcast(:message, {:server, "Good guys win!"})
        broadcast(:update, %{state | stage: :end_game})
        state

      {:continue, _} ->
        %{
          players: Enum.map(state.players, fn player -> %Player{player | on_quest: false} end),
          quest_outcomes: new_quest_outcomes,
          stage: :init,
          team_votes: default_votes(state.players),
          quest_votes: %{},
          team_rejection_count: state.team_rejection_count
        }
    end
  end

  # check if bad guys or good guys have won
  defp check_win_condition(quest_outcomes) do
    num_fails = Enum.count(quest_outcomes, fn result -> result == :fail end)
    num_passes = Enum.count(quest_outcomes, fn result -> result == :success end)

    cond do
      num_fails >= 3 ->
        {:end_game, :bad}

      num_passes >= 3 ->
        {:end_game, :good}

      true ->
        {:continue, nil}
    end
  end

  # assign next king, return updated players
  defp assign_next_king(players) do
    king_idx =
      case Enum.find_index(players, fn player -> player.is_king end) do
        nil -> 0
        king_idx -> king_idx
      end

    next_king_idx = rem(king_idx + 1, length(players))

    Enum.map(players, fn player ->
      if player.name == Enum.at(players, next_king_idx).name do
        %{player | is_king: true}
      else
        %{player | is_king: false}
      end
    end)
  end

  # find king from players
  defp find_king(players) do
    Enum.find(players, fn player -> player.is_king end)
  end

  defp is_team_full(players, added_player_id) do
    Enum.count(players, fn player -> player.on_quest end) >= 3 &&
      Enum.any?(players, fn player -> player.id == added_player_id end)
  end

  defp broadcast(event, payload) do
    Phoenix.PubSub.broadcast(Resistance.PubSub, "game", {event, payload})
  end

  # returns a map of default votes for team formation
  defp default_votes(players) do
    Enum.reduce(players, %{}, fn p, acc -> Map.put(acc, p.id, :approve) end)
  end

  # returns a map of default votes for quest result
  defp default_quest_votes(players) do
    Enum.reduce(players, %{}, fn p, acc ->
      if p.on_quest, do: Map.put(acc, p.id, :assist), else: acc
    end)
  end

  # determines if the quest succeeded or failed
  defp get_result(quest_votes) do
    if Enum.all?(quest_votes, fn {_, vote} -> vote == :assist end) do
      :succeed
    else
      :fail
    end
  end

  # check if quest team is approved
  defp check_team_approved(team_votes) do
    votes = Map.values(team_votes)
    half = (length(votes) / 2) |> Float.floor() |> round

    if length(votes) == 5 && Enum.count(votes, fn v -> v == :approve end) > half do
      true
    else
      false
    end
  end
end
