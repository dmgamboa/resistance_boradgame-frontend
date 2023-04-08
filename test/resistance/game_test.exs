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

end
