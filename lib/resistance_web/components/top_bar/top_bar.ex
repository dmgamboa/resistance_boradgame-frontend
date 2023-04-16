defmodule ResistanceWeb.TopBar do
  use Phoenix.Component

  import ResistanceWeb.CoreComponents
  import ResistanceWeb.TopBar.SoundToggle
  import ResistanceWeb.TopBar.QuitButton

  @doc """
  Creates the top bar
  """

  attr :muted, :any, required: true, doc: "Whether the music is muted or not"
  attr :music_file, :any, required: true, doc: "The music file to play"

  def top_bar(assigns) do
    ~H"""
        <div class="avalon-top-bar">
          <.sound_toggle muted={@muted} music_file={@music_file} />
          <Heroicons.arrow_right_on_rectangle class="w-5 h-5 cursor-pointer" />
        </div>
    """
  end
end
