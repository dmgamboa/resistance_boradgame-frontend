defmodule ResistanceWeb.CustomModals do
  use Phoenix.Component

  import ResistanceWeb.CoreComponents

  @doc """
  Creates a modal containing instructions for playing the game
  """
  attr :id, :string, default: "help_modal"

  def help_modal(assigns) do
    ~H"""
        <.modal id={"#{@id}"} class="help-modal">
            <:title>How to Play</:title>
            TODO: Add Instructions Here
        </.modal>
    """
  end

  @doc """
  Creates a modal containing credits
  """
  attr :id, :string, default: "credits_modal"
  def credits_modal(assigns) do
    ~H"""
      <.modal id={"#{@id}"} class="credits-modal">
        <:title>Credits</:title>
        TODO: Add Credits Here
      </.modal>
    """
  end
end
