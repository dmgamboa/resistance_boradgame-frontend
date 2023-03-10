defmodule Pregame.Server do
  require Logger
  use GenServer

  def start_link(_) do
    Logger.info("Starting Pregame.Server...")
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_cast({:add_player, player}, state) do
    broadcast(:new_player, player)
    {:noreply, [player | state]}
  end
  @impl true
  def handle_cast({:remove_player, player}, state) do
    broadcast(:remove_player, player)
    {:noreply, Enum.filter(state, fn p -> p != player end)}
  end

  @impl true
  def handle_call(:get_players, _from, state) do
    {:reply, state, state}
  end



  def add_player(player) do
    GenServer.cast(__MODULE__, {:add_player, player})
  end

  def get_players() do
    GenServer.call(__MODULE__, :get_players)
  end


  def remove_player(player) do
    GenServer.cast(__MODULE__, {:remove_player, player})
  end


  def subscribe() do
    Phoenix.PubSub.subscribe(Resistance.PubSub, "users")
  end

  defp broadcast(event, payload) do
    Phoenix.PubSub.broadcast(Resistance.PubSub, "users", {event, payload})
  end



end
