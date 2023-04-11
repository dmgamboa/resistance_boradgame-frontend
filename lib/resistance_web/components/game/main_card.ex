defmodule ResistanceWeb.Game.MainCard do
  use Phoenix.Component
  use Phoenix.LiveComponent

  @doc """
  Creates a card for use in the Game LiveView during the party stage
  """
  def main_card_party(assigns) do
    player = Enum.find(@players, fn p -> p.id == @csrf_token end)
    ~H"""
      <div class="avalon-main-card">
        <h1>Party Assembling Stage</h1>
        <%= if player.is_king do %>
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
    player = Enum.find(@players, fn p -> p.id == @csrf_token end)
    ~H"""
      <div class="avalon-main-card">
        <h1>Voting Stage</h1>
        <%= if player.is_king do %>
          <h3>Waiting for the voting results..</h3>
        <% else %>
          <h3>Approve the party?</h3>
          <div>
            <button>✅</button>
            <button>❌</button>
          </div>
        <% end %>
        <h3>Time Left: <%= @time_left %>s</h3>
      </div>
    """
  end

  @doc """
  Creates a card for use in the Game LiveView showing the voting results
  """
  def main_card_vote_reveal(assigns) do
    pass = Enum.count(@team_votes, fn x -> x == :approve end)
              > Enum.count(@team_votes, fn x -> x == :reject end)
    party = Enum.filter(@players, fn p -> p.on_quest end)
    ~H"""
      <div class="avalon-main-card">
        <h1>Voting Stage</h1>
        <%= if pass do %>
          <h3>Vote passed! Quest is proceeding with:</h3>
          <h3><%= join_names(party) %></h3>
        <% else %>
          <h3>Vote failed! Next King is being selected..</h3>
        <% end %>
      </div>
    """
  end

  @doc """
  Creates a card for use in the Game LiveView during the quest stage
  """
  def main_card_quest(assigns) do
    player = Enum.find(@players, fn p -> p.id == @csrf_token end)
    ~H"""
      <div class="avalon-main-card">
        <h1>Quest Stage</h1>
        <%= if player.on_quest || player.is_king do %>
          <h3>Quest in progress..</h3>
        <% else %>
          <h3>Sabotage the quest?</h3>
          <div>
            <button>✅</button>
            <button>❌</button>
          </div>
        <% end %>
        <h3>Time Left: <%= @time_left %>s</h3>
      </div>
    """
  end

  @doc """
  Creates a card for use in the Game LiveView during the quest reveal stage
  """
  def main_card_quest_reveal(assigns) do
    success = Enum.count(@quest_outcomes, fn x -> x == :fail end) == 0
    result = Enum.map(@quest_outcomes, fn x -> if x == :fail, do: ✅, else: ❌ end)
    ~H"""
      <div class="avalon-main-card">
        <h1>Quest Stage</h1>
        <%= if success do %>
          <h3>Quest success!</h3>
        <% else %>
          <h3>Quest failed!</h3>
        <% end %>
        <h3><%= join_results(result) %></h3>
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

  defp join_names([]), do: ""
  defp join_names([player]), do: player.name
  defp join_names([player | rest]), do: "#{player.name}, #{join_names(rest)}"

  defp join_results([]), do: ""
  defp join_results([result]), do: result
  defp join_results([result | rest]), do: "#{result} #{join_results(rest)}"
end
