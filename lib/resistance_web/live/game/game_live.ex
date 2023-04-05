defmodule ResistanceWeb.GameLive do
  use ResistanceWeb, :live_view

  @impl true
  def mount(params, _session, socket) do
    {:ok, assign(socket, params)}
  end
end
