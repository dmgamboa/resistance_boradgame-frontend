defmodule Pregame.Server do
  require Logger
  use GenServer

  def start_link(_) do
    Logger.info("Starting Pregame.Server...")
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_cast({:remove_player, socket}, state) do
    broadcast(:remove_player, Map.get(state, socket))
    {:noreply, Map.delete(state, socket)}
  end

  @impl true
  def handle_cast({:toggle_ready, socket}, state) do
    {name, ready} = Map.get(state,socket)
    new_state = Map.put(state, socket, {name, !ready})
    if Enum.all?(new_state, fn {_, ready} -> ready end) do
      broadcast(:start_game, :ok)
    else
      broadcast(:new_ready_player, socket)
    end
    {:noreply, new_state}
  end

  @impl true
  def handle_call({:add_player, socket, name}, _from, state) do
    case Enum.count(state) == 5 do
      true -> {:reply, :lobby_full, state}
      _ ->
        broadcast(:new_player, name)
        {:reply, :ok, Map.put(state, socket.id, name)}
    end
  end

  @impl true
  def handle_call(:get_players, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:validate_name, name}, _from, state) do
    cond do
      name_taken(name, state) ->
        {:reply, {:error, "Name is already taken."}, state}
      true -> {:reply, :ok, state}
    end
  end

  def add_player(socket, name) do
    GenServer.call(__MODULE__, {:add_player, socket, name})
  end

  def get_players() do
    GenServer.call(__MODULE__, :get_players)
  end

  def remove_player(socket) do
    GenServer.cast(__MODULE__, {:remove_player, socket})
  end

  def subscribe() do
    Phoenix.PubSub.subscribe(Resistance.PubSub, "pregame")
  end

  def toggle_ready(socket) do
    GenServer.cast(__MODULE__, {:toggle_ready, socket})
  end

  def validate_name(name) do
    GenServer.call(__MODULE__, {:validate_name, name})
  end

  defp broadcast(event, payload) do
    Phoenix.PubSub.broadcast(Resistance.PubSub, "pregame", {event, payload})
  end

  defp name_taken(name, players) do
    players
    |> Map.values()
    |> Enum.any?(fn {n, _} -> n == name end)
  end
end
