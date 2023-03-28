defmodule ResistanceWeb.HomeLive do
  use ResistanceWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    form = to_form(%{
      "name" => ""
    })
    {:ok, assign(socket, %{form: form})}
  end

  @impl true
  def handle_event("join", %{"name" => name}, socket) do
    case Pregame.Server.join_lobby(name) do
      :lobby_full -> {:noreply, socket}
      :name_taken -> {:noreply, socket}
      _ -> {:noreply, push_navigate(socket, to: "/lobby")}
    end
  end
end
