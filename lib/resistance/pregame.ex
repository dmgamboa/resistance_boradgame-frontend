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
  def handle_cast({:remove_player, id}, state) do
    new_state = Map.delete(state, id)
    broadcast(:update, new_state)
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:toggle_ready, id}, state) do
    {name, ready} = Map.get(state, id)
    new_state = Map.put(state, id, {name, !ready})
    case Enum.count(new_state) == max_players()
      && Enum.all?(new_state, fn {_, {_, ready}} -> ready end) do
      true ->
        broadcast(:start_timer, new_state)
        :timer.send_after(5000, self(), :start_game)
      _ -> broadcast(:update, new_state)
    end
    {:noreply, new_state}
  end

  @impl true
  def handle_call({:add_player, id, name}, _from, state) do
    cond do
      valid_name(name, state) != :ok -> {:reply, valid_name(name, state), state}
      Enum.count(state) == max_players() -> {:reply, :lobby_full, state}
      true ->
        new_state = Map.put(state, id, {name, false})
        broadcast(:update, new_state)
        {:reply, :ok, new_state}
    end
  end

  @impl true
  def handle_call(:get_players, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:is_player, id}, _from, state) do
    {:reply, Map.get(state, id) != nil, state}
  end

  @impl true
  def handle_call({:validate_name, name}, _from, state) do
    {:reply, valid_name(name, state), state}
  end

  @impl true
  def handle_info(:start_game, state) do
    if Enum.count(state) == max_players() do
      Game.Server.start_link(state)
    end
    {:noreply, state}
  end

  # Client API

  def add_player(id, name) do
    GenServer.call(__MODULE__, {:add_player, id, name})
  end

  def is_player(id) do
    GenServer.call(__MODULE__, {:is_player, id})
  end

  def get_players() do
    GenServer.call(__MODULE__, :get_players)
  end

  def remove_player(id) do
    GenServer.cast(__MODULE__, {:remove_player, id})
  end

  def subscribe() do
    Phoenix.PubSub.subscribe(Resistance.PubSub, "pregame")
  end

  def toggle_ready(id) do
    GenServer.cast(__MODULE__, {:toggle_ready, id})
  end

  def validate_name(name) do
    GenServer.call(__MODULE__, {:validate_name, name})
  end

  # Helper Functions

  defp broadcast(event, payload) do
    Phoenix.PubSub.broadcast(Resistance.PubSub, "pregame", {event, payload})
  end

  defp valid_name(name, players) do
    cond do
      name_taken(name, players) -> {:error, "Name is already taken."}
      true -> :ok
    end
  end

  defp name_taken(name, players) do
    players
    |> Map.values()
    |> Enum.any?(fn {n, _} -> n == name end)
  end

  def max_players(), do: 1
end
