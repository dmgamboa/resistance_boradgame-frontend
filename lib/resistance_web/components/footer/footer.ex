defmodule ResistanceWeb.Footer do
  use Phoenix.Component

  @doc """
  Creates the footer
  """

  def footer(assigns) do
    ~H"""
        <div class="avalon-footer">
          <p class="dimmed"> &#169 2023 All Rights Reserved ~ BCIT Comp 4959 Set V</p>
        </div>
    """
  end
end
