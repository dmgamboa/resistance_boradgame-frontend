defmodule ResistanceWeb.TopBar do
  use Phoenix.Component

  import ResistanceWeb.CoreComponents
  import ResistanceWeb.TopBar.SoundToggle
  import ResistanceWeb.TopBar.QuitButton

  @doc """
  Creates the top bar
  """

  def top_bar(assigns) do
    ~H"""
        <div class="avalon-top-bar">
          <.sound_toggle />

          <.quit_button />
        </div>
    """
  end
end
