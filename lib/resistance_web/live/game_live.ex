defmodule ResistanceWeb.GameLive do
  use ResistanceWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <h1 class="text-2xl font-bold text-center">Resistance</h1>
      <div class="mt-4">
        <h2 class="text-xl font-bold">Players</h2>
        <ul class="mt-2">
          <%= for player <- @players do %>
            <li><%= player %></li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  @impl true
  def mount(params, session, socket) do
    case connected?(socket) do
      true -> connected_mount(params, session, socket)
      false ->
        socket = socket |> assign(:players, []) |> assign(:self, nil)
        {:ok, socket, temporary_assigns: []}
    end
  end

  def connected_mount(_params, _session, socket) do
    Pregame.Server.subscribe()
    players = Pregame.Server.get_players()

    playernum = length(players) + 1
    Pregame.Server.add_player("Player #{playernum}")
    socket = socket |> assign(:players, players) |> assign(:self, "Player #{playernum}")
    {:ok, socket, temporary_assigns: []}
  end


  @impl true
  def handle_info({:new_player, player}, socket) do
    {:noreply, update(socket, :players, fn players -> [player | players] end)}
  end

  @impl true
  def handle_info({:remove_player, player}, socket) do
    {:noreply, update(socket, :players, fn players -> Enum.filter(players, fn p -> p != player end) end)}
  end

  @impl true
  def terminate(reason, socket) do
    Pregame.Server.remove_player(socket.assigns.self)
  end

end
