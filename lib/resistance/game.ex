defmodule Game.Server do
  use GenServer
  @doc """
  Store game state
  """

  #public APIs
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

  def vote_for_mission(player_name, vote) do
    GenServer.cast(__MODULE__, {:vote_for_mission, player_name, vote})
  end


  # return a list of players, with 1/3 of them being bad and the rest being good
  # assign the first player in the list to be the king
  def ramdomly_assign_roles(player_names) do
    num_bad = Enum.count(player_names) / 3 |> Float.ceil |> round

    shuffled_players = Enum.shuffle(player_names)
    Enum.map(shuffled_players, fn name ->
      index = Enum.find_index(shuffled_players, &(&1 == name))
      if index < num_bad do
        Player.new(name, :bad, false)
      else
        Player.new(name, :good, false)
      end
    end)
  end

  @impl true
  def init(player_names) do
    # feel free to amend the state
    state = %{
      players: ramdomly_assign_roles(player_names),   # a list of Player, order never change during the game
      missions: [],       #[:success | :fail]   #current_mission = length(missions) + 1
      current_king:  nil, # a string, player's name
      current_team: nil,      #[player]
      current_vote: nil,      #[{string (player), :approve | :reject}]
      current_mission_votes: [],  #[:success | :fail]
    }
    {:ok, state}
  end


  # return a player object that is the king
  @impl true
  def handle_call(:get_king, _from, state) do
    {:reply, state.current_king, state}
  end

  # return a list of players
  @impl true
  def handle_call(:get_players, _from, state) do
    {:reply, state.players, state}
  end

  # get one particular player by his/her name
  @impl true
  def handle_call({:get_player_info, player_name}, _from, state) do
    player = Enum.find(state.players, fn player -> player.name == player_name end)
    {:reply, player, state}
  end



  ### subscribe and broadcast functions
  def subscribe() do
    Phoenix.PubSub.subscribe(Resistance.PubSub, "game")
  end

  defp broadcast(event, payload) do
    Phoenix.PubSub.broadcast(Resistance.PubSub, "game", {event, payload})
  end



end
