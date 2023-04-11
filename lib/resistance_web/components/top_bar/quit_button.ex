defmodule ResistanceWeb.TopBar.QuitButton do
  use Phoenix.Component

  def quit_button(assigns) do
    ~H"""
      <span class="avalon-quit-button" phx-click="exit_lobby">
        Quit Button
      </span>
    """
  end
end
