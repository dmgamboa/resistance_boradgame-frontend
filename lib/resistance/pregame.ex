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
    {:noreply, [{player, false} | state]}
  end
  @impl true
  def handle_cast({:remove_player, player}, state) do
    broadcast(:remove_player, player)
    {:noreply, Enum.filter(state, fn {p, _} -> p != player end)}
  end

  @impl true
  def handle_cast({:ready_player, player}, state) do
    new_state = Enum.map(state, fn {p, ready} -> if p == player, do: {p, true}, else: {p, ready} end)
    if Enum.all?(new_state, fn {_, ready} -> ready end) do
      broadcast(:start_game, :ok)
    else
      broadcast(:new_ready_player, player)
    end
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:unready_player, player}, state) do
    broadcast(:remove_ready_player, player)
    {:noreply, Enum.map(state, fn {p, ready} -> if p == player, do: {p, false}, else: {p, ready} end)}
  end

  @impl true
  def handle_call(:get_players, _from, state) do
    {:reply, state, state}
  end


  def add_player(player) do
    GenServer.cast(__MODULE__, {:add_player, player})
  end

  def remove_player(player) do
    GenServer.cast(__MODULE__, {:remove_player, player})
  end

  def get_players() do
    GenServer.call(__MODULE__, :get_players)
  end



  def ready_player(player) do
    GenServer.cast(__MODULE__, {:ready_player, player})
  end

  def unready_player(player) do
    GenServer.cast(__MODULE__, {:unready_player, player})
  end


  def subscribe() do
    Phoenix.PubSub.subscribe(Resistance.PubSub, "pregame")
  end

  defp broadcast(event, payload) do
    Phoenix.PubSub.broadcast(Resistance.PubSub, "pregame", {event, payload})
  end



end
