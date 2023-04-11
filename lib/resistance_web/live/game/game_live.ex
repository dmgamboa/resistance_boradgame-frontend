defmodule ResistanceWeb.GameLive do
  use ResistanceWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    id = session["_csrf_token"]
    init_state = socket
    |> assign(:self, session["_csrf_token"])
    |> assign(:form, to_form(%{"message" => ""}))
    |> assign(:messages, [])
    cond do
      GenServer.whereis(Game.Server) == nil || !Game.Server.is_player(id) ->
        {:ok, init_state}
      true ->
        Game.Server.subscribe()
        state = Game.Server.get_state
        {:ok, init_state
          |> assign(:state, state)
          |> assign(:self, get_self(id, state.players))}
    end
  end

  @impl true
  def handle_params(_params, _url, %{assigns: %{self: self} } = socket) do
    cond do
      GenServer.whereis(Game.Server) == nil || !Game.Server.is_player(self.id) ->
        {:noreply, push_navigate(socket, to: "/")}
      true ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:message, msg}, socket) do
    {:noreply, socket
      |> assign(:form, to_form(%{"message" => ""}))
      |> assign(:messages, [msg | socket.assigns.messages])}
  end

  @impl true
  def handle_info({:update, state}, socket) do
    IO.puts("Stage: #{inspect state.stage}")
    {:noreply, socket
      |> assign(:state, state)
      |> assign(:self, get_self(socket.assigns.self.id, state.players))}
  end

  @impl true
  def handle_event("message", %{"message" => msg}, socket) do
    if (String.trim(msg) != "") do
      Game.Server.message(socket.assigns.self, msg)
    end
    {:noreply, socket |> assign(:form, to_form(%{"message" => ""}))}
  end

  defp get_self(id, players) do
    Enum.find(players, fn p -> p.id == id end)
  end
end
