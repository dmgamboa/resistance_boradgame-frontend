defmodule Pregame.ServerTest do
  use ExUnit.Case, async: false

  alias Pregame.Server

  setup do
    {:ok, pid} = Server.start_link([])
    on_exit(fn ->
      GenServer.stop(pid)
    end)
    {:ok, %{pid: pid}}
  end

  test "add_player/2 adds a player to the pregame lobby" do
    assert :ok == Server.add_player(1, "Alice")
    assert %{1 => {"Alice", false}} == Server.get_players()
  end

  test "is_player/1 returns true if the player is in the pregame lobby" do
    Server.add_player(1, "Alice")
    assert true == Server.is_player(1)
    assert false == Server.is_player(2)
  end

  test "get_players/0 returns a map of player ids to {name, ready} tuples" do
    Server.add_player(1, "Alice")
    Server.add_player(2, "Bob")
    assert %{1 => {"Alice", false}, 2 => {"Bob", false}} == Server.get_players()
  end

  test "remove_player/1 removes a player from the pregame lobby" do
    Server.add_player(1, "Alice")
    Server.add_player(2, "Bob")
    Server.remove_player(1)
    assert %{2 => {"Bob", false}} == Server.get_players()
  end

  test "toggle_ready/1 toggles a player's ready status" do
    Server.add_player(1, "Alice")
    Server.toggle_ready(1)
    assert %{1 => {"Alice", true}} == Server.get_players()
  end

  test "validate_name/1 returns :ok if the name is valid, or {:error, reason} if the name is invalid" do
    assert :ok == Server.validate_name("Alice")
    Server.add_player(1, "Alice")
    assert {:error, "Name is already taken."} == Server.validate_name("Alice")
  end
end
