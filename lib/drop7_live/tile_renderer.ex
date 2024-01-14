defmodule Drop7.TileRenderer do
  @moduledoc """
  Functions for rendering tiles.
  """

  def render_tile_map(tile_map) do
    Enum.map(Enum.with_index(tile_map), fn {col, x} ->
      tiles =
        Enum.map(Enum.with_index(col), fn {value, y} ->
          tile(value)
        end)

      empty_slots =
        Enum.map(
          Enum.with_index(List.duplicate(:empty, 7 - Enum.count(col))),
          fn {_, i} ->
            empty()
          end
        )

      [overflow() | Enum.reverse(tiles ++ empty_slots)]
    end)
  end

  def empty do
    %{
      type: :empty,
    }
  end

  def tile(value) do
    %{
      id: UUID.uuid4(),
      type: :tile,
      value: value,
    }
  end

  def overflow do
    %{
      type: :overflow,
    }
  end

  def egg do
    %{
      type: :egg,
    }
  end

  def cracked do
    %{
      type: :cracked,
    }
  end
end
