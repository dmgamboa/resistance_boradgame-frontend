defmodule ResistanceWeb.LobbyLive do
  use ResistanceWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    init_state = socket |> assign(:players, %{}) |> assign(:time_to_start, nil)
    case Pregame.Server.is_player(socket) do
      false -> {:ok, init_state}
      true ->
        Pregame.Server.subscribe()
        {:ok, init_state |> assign(:players, Pregame.Server.get_players)}
    end
  end

  @impl true
  def handle_params(_params, _url, socket) do
    case Pregame.Server.is_player(socket) do
      false -> {:noreply, push_navigate(socket, to: "/")}
      true -> {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:update, players}, socket) do
    state = socket |> assign(:players, players) |> assign(:time_to_start, nil)
    {:noreply, state}
  end

  @impl true
  def handle_info({:start_timer, players}, socket) do
    :timer.send_interval(1000, self(), :tick)
    {:noreply, socket |> assign(:players, players) |> assign(:time_to_start, 5)}
  end

  @impl true
  def handle_info(:tick, %{assigns: %{time_to_start: s}} = socket) do
    case s do
      nil -> {:noreply, socket}
      0 -> {:noreply, push_navigate(socket, to: "/game")}
      _ -> {:noreply, socket |> assign(:time_to_start, s - 1)}
    end
  end

  @impl true
  def handle_event("toggle_ready", _params, socket) do
    Pregame.Server.toggle_ready(socket)
    {:noreply, socket}
  end

  @impl true
  def terminate(_reason, socket) do
    Pregame.Server.remove_player(socket)
  end
end
