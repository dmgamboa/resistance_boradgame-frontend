defmodule Player do
  defstruct [
    :name,
    :role,
    :is_king
  ]

  def new(name, role, is_king) do
    %Player{name: name, role: role, is_king: is_king}
  end
end

defmodule Game.Server do
  use GenServer
  @doc """
  Store game state
  """

  #public APIs

  def start_link(player_names) do
    GenServer.start_link(__MODULE__, player_names, name: __MODULE__)
  end

  # don't account for player leaving for now
  # def remove_player(player_name) do
  #   GenServer.cast(__MODULE__, {:remove_player, player_name})

  # end

  def get_player_info(player_name) do
    GenServer.call(__MODULE__, {:get_player_info, player_name})
  end

  def get_players() do
    GenServer.call(__MODULE__, :get_players)
  end

  def get_king() do
    GenServer.call(__MODULE__, :get_king)
  end

  def add_quest_member(player_name) do
    GenServer.cast(__MODULE__, {:add_quest_member, player_name})
  end

  def remove_quest_member(player_name) do
    GenServer.cast(__MODULE__, {:remove_quest_member, player_name})
  end

  def confirm_team() do
    GenServer.cast(__MODULE__, :confirm_team)
  end

  def vote_for_team(player_name, vote) do
    GenServer.cast(__MODULE__, {:vote_for_team, player_name, vote})
  end

  def vote_for_mission(vote) do
    GenServer.cast(__MODULE__, {:vote_for_mission, vote})
  end


  @doc """
  return a list of players, with 1/3 of them being bad and the rest being good
  assign the first player in the list to be the king
  """
  defp make_players(player_names) do
    num_bad = Enum.count(player_names) / 3 |> Float.ceil |> round
    num_good = length(player_names) - num_bad
    roles = Enum.shuffle(List.duplicate(:good, num_good) ++ List.duplicate(:bad, num_bad))

    Enum.zip_with(player_names, roles, fn name, role ->
      if name == List.first(player_names) do
        Player.new(name, role, true)
      else
        Player.new(name, role, false)
      end
    end)
  end

  @impl true
  def init([king | _] = player_names) do
    # TODO: remove current_king, use the function find_king instead
    state = %{
      players: make_players(player_names),   # a list of Player, order never change during the game
      mission_results: [],       #[:success | :fail]   #current_mission = length(mission_results) + 1
      current_king: king, # a string, player's name
      current_team: [],      #[string (player name)]
      current_vote: [],      #[{string (player name), :approve | :reject}]
      current_mission_votes: [],  #[:success | :fail]
      team_rejection_count: 0
    }
    {:ok, state}
  end

  # get one particular player by his/her name
  @impl true
  def handle_call({:get_player_info, player_name}, _from, state) do
    player = Enum.find(state.players, fn player -> player.name == player_name end)
    {:reply, player, state}
  end

  # return a list of players
  @impl true
  def handle_call(:get_players, _from, state) do
    {:reply, state.players, state}
  end

  # return the name of the king
  @impl true
  def handle_call(:get_king, _from, state) do
    {:reply, state.current_king, state}
  end

  @doc """
  add a player to the current mission team and broadcast
  """
  @impl true
  def handle_cast({:add_quest_member, player_name}, state) do
    new_team = [player_name | state.current_team]
    broadcast(:add_quest_member, player_name)
    {:noreply, %{state | current_team: new_team}}
  end

  @doc """
  remove a player from the current mission team and broadcast
  """
  @impl true
  def handle_cast({:remove_quest_member, player_name}, state) do
    new_team = Enum.filter(state.current_team, fn name -> name != player_name end)
    broadcast(:remove_quest_member, player_name)
    {:noreply, %{state | current_team: new_team}}
  end

  @impl true
  def handle_cast(:confirm_team, state) do
    broadcast(:team_formed, state.current_team)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:vote_for_team, player_name, vote}, state) do
    new_vote = [{player_name, vote} | state.current_vote]
    if length(new_vote) == length(state.players) do # everyone has voted
      half = length(state.players) / 2 |> Float.ceil |> round
      if Enum.count(new_vote, fn {_, vote} -> vote == :approve end) > half do
        broadcast(:team_approved, new_vote)
        {:noreply, %{state | current_vote: new_vote}}
      else
        broadcast(:team_rejected, new_vote)
        {:noreply, start_next_round(state, nil)}
      end

    else
      {:noreply, %{state | current_vote: new_vote}}
    end

  end

  @impl true
  def handle_cast({:vote_for_mission, vote}, state) do
    new_mission_vote = [vote | state.current_mission_votes]
    if length(new_mission_vote) == length(state.current_team) do

      if Enum.all?(new_mission_vote, fn vote -> vote == :success end) do
        broadcast(:mission_success, new_mission_vote)
        {:noreply, start_next_round(state, :sucess)}
      else
        broadcast(:mission_fail, new_mission_vote)
        {:noreply, start_next_round(state, :fail)}
      end

    else
      {:noreply, %{state | current_mission_votes: new_mission_vote}}
    end
  end

  @doc """
  start next round, return updated state
  TODO: should probably wait for all clients to confirm before starting next round,
  this means adding a new key in state to keep track of which clients have confirmed
  NOTE: if team is rejected, mission_result is nil
  """
  defp start_next_round(state, mission_result) do
    updated_players = assign_next_king(state.current_king, state.players)
    next_king = find_king(updated_players).name
    broadcast(:start_next_round, next_king)   # broadcast to clients to start next round

    %{
      players: updated_players,
      mission_results:
        case do
          nil -> state.mission_results
          _ -> state.mission_results ++ [mission_result]
        end,
      current_king: next_king,
      current_team: [],
      current_vote: [],
      current_mission_votes: [],
      team_rejection_count:
        case mission_result do
          nil -> state.team_rejection_count + 1
          _ -> state.team_rejection_count
        end
    }

  end

  # assign next king, return updated players
  defp assign_next_king(current_king, players) do
    king_idx = Enum.find_index(players, fn player -> player.name == current_king end)
    next_king_idx = rem((king_idx + 1), length(players))
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

  ### subscribe and broadcast functions
  def subscribe() do
    Phoenix.PubSub.subscribe(Resistance.PubSub, "game")
  end

  defp broadcast(event, payload) do
    Phoenix.PubSub.broadcast(Resistance.PubSub, "game", {event, payload})
  end


end
