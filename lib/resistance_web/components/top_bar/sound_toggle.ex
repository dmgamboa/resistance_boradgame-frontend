defmodule ResistanceWeb.TopBar.SoundToggle do
  use Phoenix.Component

  def sound_toggle(assigns) do
    ~H"""
    <button
      id="sound-toggle-btn"
      phx-hook="ToggleSound"
      type="button"
      class="-m-3 flex-none p-3 hover:opacity-40"
      aria-label="toggle"
    >
      <Heroicons.speaker_wave solid class="h-5 w-5 stroke-current" />
    </button>
    """
  end
end
