defmodule ResistanceWeb.LobbyLive do
  use ResistanceWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    case Pregame.Server.is_player(socket) do
      false -> {:ok, assign(socket, %{players: %{}})}
      true ->
        Pregame.Server.subscribe()
        {:ok, assign(socket, %{players: Pregame.Server.get_players})}
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
    {:noreply, assign(socket, %{players: players})}
  end

  @impl true
  def handle_event("toggle_ready", socket) do
    Pregame.Server.toggle_ready(socket)
    {:noreply, socket}
  end

  @impl true
  def terminate(_reason, socket) do
    Pregame.Server.remove_player(socket)
  end

end
