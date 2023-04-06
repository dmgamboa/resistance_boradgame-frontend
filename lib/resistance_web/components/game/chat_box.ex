defmodule ResistanceWeb.Game.ChatBox do
  use Phoenix.Component

  import ResistanceWeb.CoreComponents

  @doc """
  Creates a chat box for use in the Game LiveView
  """

  def chat_box(assigns) do
    ~H"""
      <div class="avalon-chat-box">
        Chat Box
      </div>
    """
  end
end
