defmodule ResistanceWeb.HomeLive do
  use ResistanceWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    form = to_form(%{"name" => ""})
    {:ok, assign(socket, %{form: form})}
  end

  @impl true
  def handle_event("validate", %{"name" => name} = param, socket) do
    case Pregame.Server.validate_name(name) do
      {:error, msg} ->
        {:noreply, assign(socket, :form, to_form(param, errors: [name: {msg, []}]))}
      _ ->
        {:noreply, assign(socket, :form, to_form(param))}
    end
  end

  @impl true
  def handle_event("join", %{"name" => name} = param, socket) do
    case Pregame.Server.add_player(socket, String.trim(name)) do
      :lobby_full ->
        # TODO: Show Lobby Full Modal
        {:noreply, socket}

      {:error, msg} ->
        {:noreply, assign(socket, :form, to_form(param, errors: [name: {msg, []}]))}
      _ ->
        {:noreply, push_navigate(socket, to: "/lobby")}
    end
  end
end
