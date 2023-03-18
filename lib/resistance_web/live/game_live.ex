defmodule ResistanceWeb.GameLive do
  use ResistanceWeb, :live_view
  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <h1 class="text-2xl font-bold text-center">Resistance</h1>
      <div class="mt-4">
        <h2 class="text-xl font-bold">Players</h2>
        <ul class="mt-2">
          <%= for {player, ready} <- @players do %>
            <li>
              <%= player %>
              <%= if player == @self do %>
                (You)
              <% end %>

              <%= if ready do %>
                ✓
              <% end %>

            </li>
          <% end %>
        </ul>
      </div>

      <div class="mt-4">
        <a href="#"
           phx-click="toggle_start"
           class="block w-full px-4 py-2 text-center text-white bg-blue-500 rounded hover:bg-blue-600">
           <%= if @ready do %>
              Cancel Start
            <% else %>
              Start Game
            <% end %>
        </a>
      </div>

    </div>
    """
  end

  @impl true
  def mount(params, session, socket) do
    case connected?(socket) do
      true -> connected_mount(params, session, socket)
      false ->
        socket = assign(socket, players: [], self: nil, ready: false)
        {:ok, socket, temporary_assigns: []}
    end
  end

  def connected_mount(_params, _session, socket) do
    Pregame.Server.subscribe()
    players = Pregame.Server.get_players()

    playernum = length(players) + 1
    Pregame.Server.add_player("Player #{playernum}")
    socket = assign(socket, players: players, self: "Player #{playernum}", ready: false)
    {:ok, socket, temporary_assigns: []}
  end

  @impl true
  def handle_info({:start_game, :ok}, socket) do
    Logger.info("Starting game...")


    {:noreply, push_navigate(socket, to: "/game")}
  end

  @impl true
  def handle_info({_, _}, socket) do
    {:noreply, update(socket, :players, fn _ -> Pregame.Server.get_players() end)}
  end
  # @impl true
  # def handle_info({:remove_player, player}, socket) do
  #   {:noreply, update(socket, :players, fn _ -> Pregame.Server.get_players() end)}
  # end

  # @impl true
  # def handle_info({:new_ready_player, player}, socket) do
  #   {:noreply, update(socket, :players, fn _ -> Pregame.Server.get_players() end)}
  # end
  # @impl true
  # def handle_info({:remove_ready_player, player}, socket) do
  #   {:noreply, update(socket, :players, fn _ -> Pregame.Server.get_players() end)}
  # end

  @impl true
  def handle_event("toggle_start", _params, socket) do
    if socket.assigns.ready do
      Pregame.Server.unready_player(socket.assigns.self)
    else
      Pregame.Server.ready_player(socket.assigns.self)
    end
    {:noreply, update(socket, :ready, &(!&1))}
  end

  @impl true
  def terminate(_reason, socket) do
    Pregame.Server.remove_player(socket.assigns.self)
  end

end
