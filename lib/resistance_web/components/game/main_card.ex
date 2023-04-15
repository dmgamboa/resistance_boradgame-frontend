defmodule ResistanceWeb.Game.MainCard do
  use Phoenix.Component
  import ResistanceWeb.CoreComponents

  @doc """
  Creates a card for use in the Game LiveView during the party stage
  """
  def main_card_party(assigns) do
    ~H"""
      <div class="avalon-main-card">
        <h1>Party Assembling Stage</h1>
        <%= if @self.is_king do %>
          <h3>Choose a party of 3</h3>
        <% else %>
          <h3>Waiting for the King to choose the party members..</h3>
        <% end %>
        <h3>Time Left: <%= @time_left %>s</h3>
      </div>
    """
  end

  @doc """
  Creates a card for use in the Game LiveView during the voting stage
  """
  def main_card_vote(assigns) do
    ~H"""
      <div class="avalon-main-card">
        <h1>Voting Stage</h1>
        <%= if @self.is_king do %>
          <h3>Waiting for the voting results..</h3>
        <% else %>
          <h3>Approve the party?</h3>
          <div>
            <.button phx-click={@on_vote} phx-value-vote={:approve}>
              Approve
            </.button>
            <.button phx-click={@on_vote} phx-value-vote={:reject}>
              Reject
            </.button>
          </div>
        <% end %>
        <h3>Time Left: <%= @time_left %>s</h3>
      </div>
    """
  end

  @doc """
  Creates a card for use in the Game LiveView during the quest stage
  """
  def main_card_quest(assigns) do
    ~H"""
      <div class="avalon-main-card">
        <h1>Quest Stage</h1>
        <%= if @self.role == :bad && @self.on_quest do %>
          <h3>Sabotage the quest?</h3>
          <div>
            <.button phx-click={@on_vote} phx-value-vote={:sabotage}>
              Sabotage
            </.button>
            <.button phx-click={@on_vote} phx-value-vote={:assist}>
              Assist
            </.button>
          </div>
        <% else %>
          <h3>Quest in progress..</h3>
        <% end %>
        <h3>Time Left: <%= @time_left %>s</h3>
      </div>
    """
  end

  @doc """
  Creates a card for use in the Game LiveView during the quest reveal stage
  """
  def main_card_quest_reveal(assigns) do
    ~H"""
      <div class="avalon-main-card">
        <h1>Quest Stage</h1>
        <%= if @success do %>
          <h3>Quest success!</h3>
        <% else %>
          <h3>Quest failed!</h3>
        <% end %>
        <h3><%= join_results(@result) %></h3>
      </div>
    """
  end

  def main_card_wait(assigns) do
    ~H"""
      <div class="avalon-main-card">
        <h1>Waiting...</h1>
      </div>
    """
  end

  defp join_results([]), do: ""
  defp join_results([result]), do: result
  defp join_results([result | rest]), do: "#{result} #{join_results(rest)}"
end
