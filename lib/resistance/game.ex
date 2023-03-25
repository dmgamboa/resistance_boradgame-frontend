defmodule Game.Server do
  use GenServer
  @doc """
  Store game state
  """

  def start_link(player_names) do
    GenServer.start_link(__MODULE__, player_names, name: __MODULE__)
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



end
