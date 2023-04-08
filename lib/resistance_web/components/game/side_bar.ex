defmodule ResistanceWeb.Game.SideBar do
  use Phoenix.Component

  @doc """
  Creates a side bar for use in the Game LiveView
  """

  def side_bar(assigns) do
    ~H"""
        <div class="avalon-side-bar">
          Side Bar
        </div>
    """
  end
end
