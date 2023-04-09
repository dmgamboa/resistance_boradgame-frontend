defmodule Resistance.GameTest do
  use ExUnit.Case, async: true
  import Phoenix.ChannelTest

  alias Resistance.Game.Server

  test "create new player" do
    player = Player.new(1, "Alice", :good)
    assert player.id == 1
    assert player.name == "Alice"
    assert player.role == :good
    assert player.is_king == false
    assert player.on_quest == false
  end

  test "player becomes king" do
    player = Player.new(1, "Alice", :good)
    player_king = Player.become_king(player)
    assert player_king.is_king == true
  end

end
