defmodule Drop7.TileRenderer do
  @moduledoc """
  Functions for rendering tiles.
  """

  @size 30

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

  def color(1), do: "#66be7b"
  def color(2), do: "#fed452"
  def color(3), do: "#fbb050"
  def color(4), do: "#e74d5f"
  def color(5), do: "#ed75c9"
  def color(6), do: "#4dd2f9"
  def color(7), do: "#3a87c5"
  def color(:egg), do: "#f9fbfc"
  def color(:cracked), do: "#ecf2f4"
  def color(:empty), do: "#294673"
  def color(:overflow), do: "grey"

  def empty do
    %{
      color: color(:empty),
      type: :empty,
      size: @size
    }
  end

  def tile(value) do
    %{
      color: color(value),
      id: UUID.uuid4(),
      type: :tile,
      value: value,
      size: @size
    }
  end

  def overflow do
    %{
      color: color(:overflow),
      type: :overflow,
      size: @size
    }
  end

  def egg do
    %{
      color: color(:egg),
      type: :egg,
      size: @size
    }
  end

  def cracked do
    %{
      color: color(:cracked),
      type: :cracked,
      size: @size
    }
  end
end
