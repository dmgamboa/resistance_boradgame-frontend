defmodule ResistanceWeb.Game.SideBar do
  use Phoenix.Component
  import ResistanceWeb.CoreComponents

  @doc """
  Creates a side bar for use in the Game LiveView
  """

  attr :quest_outcomes, :any, default: []
  attr :players, :any, default: []
  attr :self, Player, required: true
  attr :stage, :any, required: true
  attr :team_votes, :any, default: %{}
  attr :on_select_player, :any

  def side_bar(assigns) do
    ~H"""
        <div class="avalon-side-bar">
          <.quest_outcomes quest_outcomes={@quest_outcomes}/>
          <.role role={@self.role} />
          <.player_list
            players={@players}
            self={@self}
            team_votes={@team_votes}
            stage={@stage}
            on_select_player={@on_select_player}
          />
        </div>
    """
  end

  @doc """
  Creates the quest outcomes component
  """

  attr :quest_outcomes, :any, default: []

  def quest_outcomes(assigns) do
    ~H"""
      <div class="quest-outcomes">
        <%=Enum.map(@quest_outcomes, fn q -> %>
          <div class="outcome">
            <%= if q == :success do %>
              <span>✅</span>
            <% end %>
            <%= if q == :fail do %>
              <span>❌</span>
            <% end %>
          </div>
        <% end) %>
      </div>
    """
  end

  @doc """
  Creates the role section
  """

  attr :role, :any, required: true

  def role(assigns) do
    ~H"""
      <div class="role">
        You are
        <%= if @role == :good do %>
          Arthur's knight
        <% end %>

        <%= if @role == :bad do %>
          Mordred's minion
        <% end %>
      </div>
    """
  end

  @doc """
  Creates an interactable list of players in the game
  """

  attr :players, :any, default: []
  attr :self, Player, required: true
  attr :stage, :any, required: true
  attr :team_votes, :any, required: true
  attr :on_select_player, :any, default: "player_list_btn_click"

  def player_list(assigns) do
    ~H"""
      <div class="player-list">
        <%= Enum.map(@players, fn p -> %>
          <div class="player">
          <span class={
              case @self.role == :bad && p.role == :bad do
                true -> "name bad"
                false -> "name"
              end}>
              <%= p.name %>
              <%= if p.is_king do %>
                👑
              <% end %>
            </span>

            <span class="vote">

              <%= if @stage == :voting do %>
                <%= case @team_votes[p.id] do %>
                <% :approve -> %> 👍
                <% :reject -> %> 👎
                <% end %>
              <% end %>

              <%= if @stage == :quest && p.on_quest do %>
              🏆
              <% end %>
            </span>

            <%= if @stage == :party_assembling && @self.is_king do %>
              <.button phx-click={@on_select_player} phx-value-player={p.id}>
                <%= case p.on_quest do
                  true -> "Cancel"
                  false -> "Select"
                end %>
              </.button>
            <% end %>
          </div>
        <% end)%>
      </div>
    """
  end
end
