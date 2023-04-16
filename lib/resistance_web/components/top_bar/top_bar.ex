defmodule ResistanceWeb.TopBar do
  use Phoenix.Component

  import ResistanceWeb.CoreComponents
  import ResistanceWeb.TopBar.SoundToggle
  import ResistanceWeb.TopBar.QuitButton
  alias ResistanceWeb.TopBar.SoundToggle

  @doc """
  Creates the top bar
  """

  attr :muted, :any, required: true, doc: "Whether the music is muted or not"
  attr :music_file, :any, required: true, doc: "The music file to play"

  def top_bar(assigns) do
    ~H"""
        <div class="avalon-top-bar">
          <.live_component module={SoundToggle} muted={@muted} music_file={@music_file} id="sound-toggle" />
          <Heroicons.arrow_right_on_rectangle class="w-5 h-5 cursor-pointer" />
        </div>
    """
  end
end
