defmodule ResistanceWeb.TopBar.SoundToggle do
  use Phoenix.Component

  attr :muted, :any, required: true, doc: "Whether the music is muted or not"
  attr :music_file, :any, required: true, doc: "The music file to play"

  def sound_toggle(assigns) do
    ~H"""
    <button
      id="sound-toggle-btn"
      phx-hook="ToggleSound"
      type="button"
      class="-m-3 flex-none p-3 hover:opacity-40"
      aria-label="toggle"
    >
      <%= if @muted do %>
        <Heroicons.speaker_x_mark solid class="h-5 w-5 stroke-current" />
      <% else %>
        <Heroicons.speaker_wave solid class="h-5 w-5 stroke-current" />
      <% end %>
    </button>
    <audio id="game-audio" src={"/audio/#{@music_file}"} muted={@muted} autoplay loop preload="auto">
      Your browser does not support the audio element.
    </audio>
    """
  end
end
