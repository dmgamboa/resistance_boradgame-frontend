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
  end

  def start_link(player_names) do
    GenServer.start_link(__MODULE__, player_names, name: __MODULE__)
  end

  def remove_player(game, player_name) do
    GenServer.cast(__MODULE__, {:remove_player, player_name})

  end

  def get_player_info(game, player_name) do
    GenServer.call(__MODULE__, {:get_player_info, player_name})
  end

  def get_king(game) do
    GenServer.call(__MODULE__, :get_king)
  end

  def add_quest_member(game, player_name) do
    GenServer.cast(__MODULE__, {:add_quest_member, player_name})
  end

  def remove_quest_member(game, player_name) do
    GenServer.cast(__MODULE__, {:remove_quest_member, player_name})
  end

  def confirm_team(game) do
    GenServer.cast(__MODULE__, :confirm_team)
  end

  def vote_for_team(game, player_name, vote) do
    GenServer.cast(__MODULE__, {:vote_for_team, player_name, vote})
  end

  def vote_for_mission(game, player_name, vote) do
    GenServer.cast(__MODULE__, {:vote_for_mission, player_name, vote})
  end



  @impl true
  def init(player_names) do
    # feel free to amend the state
    state = %{
      players: Enum.map(player_names, fn name -> {name, :good} end),   #[string, :good | :bad] #TODO: randomly assign good/bad
      missions: [],       #[:success | :fail]   #current_mission = length(missions) + 1
      current_king: nil,    #string
      current_team: nil,      #[string]
      current_vote: nil,      #[{string (player), :approve | :reject}]
      current_mission_votes: [],  #[:success | :fail]
    }
    {:ok, state}
  end



  ### subscribe and broadcast functions
  def subscribe() do
    Phoenix.PubSub.subscribe(Resistance.PubSub, "game")
  end

  defp broadcast(event, payload) do
    Phoenix.PubSub.broadcast(Resistance.PubSub, "game", {event, payload})
  end



end
