defmodule ResistanceWeb.HomeLive do
  use ResistanceWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    form = to_form(%{"name" => ""})
    {:ok, assign(socket, %{form: form})}
  end

  # TODO: Check if name is valid
  # @impl true
  # def handle_event("validate", %{"name" => name}, socket) do
  #   case Pregame.Server.validate_name(name) do
  #     {:error, msg} -> {:noreply, assign(socket, )}
  #     _ -> {:noreply, socket}
  #   end
  # end

  # TODO: Don't trigger rest of "join" handler if there are errors in the form
  # @impl true
  # def handle_event("join", %{"errors" => e}, socket) when Enum.count(e) > 0 do
  #   {:noreply, socket}
  # end

  @impl true
  def handle_event("join", %{"name" => name}, socket) do
    case Pregame.Server.add_player(socket, name) do
      :lobby_full ->
        # TODO: Show Lobby Full Modal
        {:noreply, socket}
      _ -> {:noreply, push_navigate(socket, to: "/lobby")}
    end
  end
end
