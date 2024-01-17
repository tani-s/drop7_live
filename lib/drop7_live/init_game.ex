defmodule Drop7.InitGame do
  @moduledoc """
  Functions for initiating the Drop 7 game.

  For now, only Blitz mode.
  """

  alias Drop7.Utils

  @doc """
  Populates the empty board with starting tiles.
  """
  def starting_tiles() do
    # Generate a starting position.
    # There should be no popping tiles, and the tile arrangement should not cause any pops on game start.

    # come up with heights for each column
    # then populate with tiles that can satisfy the no-pop requirement

    # we shouldn't allow any column to be more than 4 high, but it could be 0 high

    populate_tile_map(blank_tile_map())
  end

  def to_game_state(game_objects) do
    %{
      game_objects: game_objects,
      score: 0,
      turn_count: 0,
      combo: 1,
      game_over: false,
      next_tile: nil
    }
  end

  def blank_tile_map() do
    heights = Enum.map(0..6, fn _ -> Enum.random(0..4) end)
    Enum.map(heights, fn height -> List.duplicate("x", height) end)
  end

  def populate_tile_map(blank_tile_map) do
    Enum.map(Enum.with_index(blank_tile_map), fn {col, x} ->
      Enum.map(Enum.with_index(col), fn {_tile, y} ->
        Enum.random(possible_tiles_for_coordinate(blank_tile_map, x, y))
      end)
    end)
  end

  def possible_tiles_for_coordinate(tile_map, x, y) do
    col_height = Utils.col_height(tile_map, x)
    row_width = Utils.row_width(tile_map, x, y)

    Enum.to_list(1..7) -- [col_height, row_width]
  end
end
