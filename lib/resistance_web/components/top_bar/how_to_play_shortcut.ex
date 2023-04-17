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
      class="-m-3 flex-none p-3 hover:opacity-40"
      aria-label="how-to-play"
    >
        <Heroicons.question_mark_circle solid class="h-5 w-5 stroke-current" />

    </button>

    <.help_modal />
    </div>
    """
  end

  def handle_event("toggle-sound", _params, socket) do
    {:noreply, socket |> assign(:muted, !socket.assigns.muted)}
  end

  def handle_event("show-how-to-play-modal", _, socket) do
    {:noreply, socket |> push_event("show_modal", %{"id" => "help_modal"})}
  end
end
