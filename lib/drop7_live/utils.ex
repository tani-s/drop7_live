defmodule Drop7.Utils do
  @moduledoc """
  Functions for checking row/column counts.
  """

  def tile_should_pop?(game_objects, x, y) do
    value = game_objects |> Enum.at(y) |> Enum.at(x) |> Map.get(:value)

    value in popping_tiles_for_coordinate(game_objects, x, y)
  end

  def popping_tiles_for_coordinate(game_objects, x, y) do
    col_height = game_object_col_height(game_objects, y)
    row_width = game_object_row_width(game_objects, x, y)

    [col_height, row_width]
  end

  def game_object_col_height(game_objects, x) do
    index = Enum.find_index(Enum.at(game_objects, x), fn
      %{type: :tile} -> true
      %{type: :egg} -> true
      %{type: :cracked} -> true
      %{type: :empty} -> false
      %{type: :overflow} -> false
    end)

    if is_nil(index) do
      0
    else
      8 - index
    end
  end

  def col_height(tile_map, x) do
    tile_map |> Enum.at(x) |> Enum.count()
  end

  def game_object_row_width(game_objects, x, y) do
    row = Enum.map(game_objects, fn col -> Enum.at(col, x) end)

    game_object_row_width(row, y)
  end

  def game_object_row_width(row, x) do
    {left, right} = Enum.split(row, x)
    left_adjacent_tiles = game_objects_before_nil(Enum.reverse(left))
    right_adjacent_tiles = game_objects_before_nil(right)

    left_adjacent_tiles + right_adjacent_tiles
  end

  def row_width(tile_map, x, y) do
    # get the number of tiles in a row block with the given coordinate
    row = Enum.map(tile_map, fn col -> Enum.at(col, y) end)

    row_width(row, x)
  end

  def row_width(row, x) do
    {left, right} = Enum.split(row, x)
    left_adjacent_tiles = tiles_before_nil(Enum.reverse(left))
    right_adjacent_tiles = tiles_before_nil(right)

    left_adjacent_tiles + right_adjacent_tiles
  end

  def tiles_before_nil(tiles) do
    Enum.reduce_while(tiles, 0, fn
      nil, acc ->
        {:halt, acc}

      _, acc ->
        {:cont, acc + 1}
    end)
  end

  def game_objects_before_nil(game_objects) do
    Enum.reduce_while(game_objects, 0, fn
      %{type: :tile}, acc ->
        {:cont, acc + 1}

      %{type: :egg}, acc ->
        {:cont, acc + 1}

      %{type: :cracked}, acc ->
        {:cont, acc + 1}

      %{type: :empty}, acc ->
        {:halt, acc}

      %{type: :overflow}, acc ->
        {:halt, acc}
    end)
  end
end
