defmodule ResistanceWeb.GameLive do
  use ResistanceWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    Game.Server.subscribe()
    init_state = socket
      |> assign(:self, session["_csrf_token"])
      |> assign(:form, to_form(%{"message" => ""}))
      |> assign(:messages, [])
    {:ok, init_state}
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
