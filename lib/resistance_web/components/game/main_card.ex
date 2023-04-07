defmodule ResistanceWeb.Game.MainCard do
  use Phoenix.Component

  @doc """
  Creates a card for use in the Game LiveView
  """

  def main_card(assigns) do
    ~H"""
        <div class="avalon-main-card">
          Main Card
        </div>
    """
  end
end
