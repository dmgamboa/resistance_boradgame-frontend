defmodule ResistanceWeb.TopBar.HowToPlayShortcut do
  use Phoenix.LiveComponent

  import ResistanceWeb.CustomModals
  import ResistanceWeb.CoreComponents

  def render(assigns) do
    ~H"""
    <div>
    <button
      id="how-to-play-shortcut-btn"
      phx-click={show_modal("help_modal")}
      phx-target={@myself}
      type="button"
      class="flex-none p-3 hover:opacity-40"
      aria-label="how-to-play"
    >
        <Heroicons.question_mark_circle solid class="h-5 w-5 stroke-current" />

    </button>

    <.help_modal />
    </div>
    """
  end

end
