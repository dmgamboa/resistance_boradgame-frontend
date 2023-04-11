defmodule ResistanceWeb.GameLive do
  use ResistanceWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    id = session["_csrf_token"]
    init_state = socket
    |> assign(:self, session["_csrf_token"])
    |> assign(:form, to_form(%{"message" => ""}))
    |> assign(:messages, [])
    case Pregame.Server.is_player(id) do
      false -> {:ok, init_state}
      true ->
        Game.Server.subscribe()
        {:ok, init_state |> assign(:players, Game.Server.get_players())}
    end
    {:ok, init_state}
  end

  @impl true
  def handle_params(_params, _url, %{assigns: %{self: self} } = socket) do
    case Pregame.Server.is_player(self) do
      false -> {:noreply, push_navigate(socket, to: "/")}
      true -> {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:message, msg}, socket) do
    {:noreply, socket
      |> assign(:form, to_form(%{"message" => ""}))
      |> assign(:messages, [msg | socket.assigns.messages])
    }
  end

  @impl true
  def handle_event("message", %{"message" => msg}, socket) do
    if (String.trim(msg) != "") do
      Game.Server.message(socket.assigns.self, msg)
    end
    {:noreply, socket |> assign(:form, to_form(%{"message" => ""}))}
  end
end
