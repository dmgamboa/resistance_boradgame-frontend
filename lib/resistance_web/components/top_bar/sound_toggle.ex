defmodule ResistanceWeb.TopBar.SoundToggle do
  use Phoenix.Component

  def sound_toggle(assigns) do
    ~H"""
      <span class="avalon-sound-toggle">
        Sound Toggle
      </span>
    """
  end
end
