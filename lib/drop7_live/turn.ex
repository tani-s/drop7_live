defmodule Drop7.Turn do
  @moduledoc """
  Functions for continuing gameplay.
  """

  alias Drop7.TileRenderer
  # game state:
  # game_objects (indexed y -> x)
  # turn count
  # score
  # game over bool
  # combo
  # next_tile

  @doc """
  Increase the height of all tiles by 1, and add a row of eggs to the bottom row.
  Adds 17,000 to the current score.
  """
  def increment_level(
        %{"game_objects" => game_objects, "score" => score} = game_state,
        prior_states
      ) do
    updated_game_objects =
      Enum.map(game_objects, fn
        [%{"type" => "overflow"} | [%{"type" => "empty"} | rest]] ->
          [TileRenderer.overflow() | rest] ++ [TileRenderer.egg()]

        [%{"type" => "overflow"} | [last_tile | rest]] ->
          [%{last_tile | "type" => "overflow"} | rest] ++ [TileRenderer.egg()]
      end)

    # print_board(updated_game_objects, "incremented level with egg row")

    new_game_state = %{
      game_state
      | "game_objects" => updated_game_objects,
        "turn_count" => 0,
        "score" => score + 17_000
    }

    if check_game_over(new_game_state) do
      [Map.put(new_game_state, "game_over", true) | [game_state | prior_states]]
    else
      pop_tiles(new_game_state, [new_game_state | [game_state | prior_states]])
    end
  end

  @doc """
  Checks if one of two conditions are met:
  - There is a non-empty overflow row
  - All slots are filled
  """
  def check_game_over(%{"game_objects" => game_objects}) do
    check_overflowing(game_objects) or check_board_full(game_objects)
  end

  defp check_board_empty(%{"game_objects" => game_objects}) do
    game_objects
    |> Enum.map(fn col ->
      Enum.map(col, fn
        # if there are any non-empty, non-overflow tiles, we're empty
        %{"type" => "empty"} ->
          true

        %{"type" => "overflow"} ->
          true

        _ ->
          false
      end)
      |> Enum.all?()
    end)
    |> Enum.all?()
  end

  defp check_board_full(game_objects) do
    game_objects
    |> Enum.map(fn col ->
      Enum.map(col, fn
        # if there is an empty tile anywhere on the board, we're safe
        %{"type" => "empty"} ->
          false

        _ ->
          true
      end)
      |> Enum.all?()
    end)
    |> Enum.all?()
  end

  defp check_overflowing(game_objects) do
    game_objects
    |> Enum.map(fn
      # if there is a tile value in any overflow slot, game over
      [%{"type" => "overflow", "value" => value} | _] ->
        true

      _ ->
        false
    end)
    |> Enum.any?()
  end

  def print_board(%{"game_objects" => game_objects}, label \\ "") do
    Enum.map(game_objects, fn col ->
      Enum.map(col, fn tile -> Map.get(tile, "value") || Map.get(tile, "type") end)
    end)
    |> IO.inspect(label: label <> " from game state")
  end

  def print_board(game_objects, label) do
    Enum.map(game_objects, fn col ->
      Enum.map(col, fn tile -> Map.get(tile, "value") || Map.get(tile, "type") end)
    end)
    |> IO.inspect(label: label)
  end

  def print_col(col, label \\ "") do
    Enum.map(col, fn tile -> Map.get(tile, "value") || Map.get(tile, "type") end)
    |> IO.inspect(label: label)
  end

  @doc """
  Removes all tiles that are in a column or row group of equal length to their value.
  Cracks any adjacent eggs. Breaks any adjacent cracked eggs.
  Moves any tiles that are now over empty slots down.
  Repeats this process until no more tiles meet this condition.
  """
  def pop_tiles(
        %{"game_objects" => game_objects, "score" => score, "combo" => combo} = game_state,
        past_states \\ []
      ) do
    to_remove =
      Enum.reduce(Enum.with_index(game_objects), MapSet.new(), fn {col, y}, col_acc ->
        to_remove_tile =
          Enum.reduce(Enum.with_index(col), col_acc, fn
            {%{"type" => "tile"} = tile, x}, acc ->
              if Drop7.Utils.tile_should_pop?(game_objects, x, y) do
                MapSet.put(acc, {x, y})
              else
                acc
              end

            {_slot_or_egg, _}, acc ->
              acc
          end)

        MapSet.union(col_acc, to_remove_tile)
      end)

    if Enum.empty?(to_remove) do
      past_states
    else
      updated_game_objects =
        Enum.reduce(to_remove, game_objects, fn {x, y}, new_game_objects ->
          new_game_objects
          |> crack_adjacent_eggs(x, y)
          |> remove_tile(x, y)
        end)

      popping_game_state = %{
        game_state
        | "game_objects" => popping_game_objects(to_remove, game_objects)
      }

      points = Enum.count(to_remove) * Drop7Live.Score.combo(combo)

      updated_game_state = %{
        game_state
        | "game_objects" => updated_game_objects,
          "score" => score + points,
          "combo" => combo + 1
      }

      pop_tiles(updated_game_state, [updated_game_state | [popping_game_state | past_states]])
    end
  end

  def popping_game_objects(to_remove, game_objects) do
    Enum.reduce(to_remove, game_objects, fn {x, y}, new_game_objects ->
      tile = get_at_coordinate(new_game_objects, x, y)

      replace_tile_with(new_game_objects, x, y, Map.put(tile, "state", " popping"))
    end)
  end

  def crack_adjacent_eggs(game_objects, x, y) do
    right = get_at_coordinate(game_objects, x, y - 1)
    left = get_at_coordinate(game_objects, x, y + 1)
    up = get_at_coordinate(game_objects, x - 1, y)
    down = get_at_coordinate(game_objects, x + 1, y)

    potential_eggs = [
      {right, x, y - 1},
      {left, x, y + 1},
      {up, x - 1, y},
      {down, x + 1, y}
    ]

    Enum.reduce(potential_eggs, game_objects, fn
      {%{"type" => "egg"}, x, y}, acc ->
        replace_tile_with(acc, x, y, TileRenderer.cracked())

      {%{"type" => "cracked"}, x, y}, acc ->
        replace_tile_with(acc, x, y, random_tile())

      _, acc ->
        acc
    end)
  end

  def random_tile() do
    TileRenderer.tile(Enum.random(1..7))
  end

  def get_at_coordinate(game_objects, x, y) when 0 <= x and x <= 7 and 0 <= y and y <= 6 do
    game_objects |> Enum.at(y) |> Enum.at(x)
  end

  def get_at_coordinate(game_objects, x, y) do
    nil
  end

  def remove_tile(game_objects, x, y) do
    col = Enum.at(game_objects, y)
    {removed, [%{"type" => "overflow"} = overflow | rest]} = List.pop_at(col, x)

    List.replace_at(game_objects, y, [overflow | [TileRenderer.empty() | rest]])
  end

  def replace_tile_with(game_objects, x, y, new_tile) do
    col = Enum.at(game_objects, y)
    new_col = List.replace_at(col, x, new_tile)

    List.replace_at(game_objects, y, new_col)
  end

  @doc """
  Adds 1 to the turn count.
  If the count is at 4, resets the count to 0 and increments the level.
  """
  def increment_turn(%{"turn_count" => 4} = game_state, prior_states) do
    increment_level(game_state, prior_states)
  end

  def increment_turn(%{"turn_count" => turn} = game_state, prior_states) do
    [%{game_state | "turn_count" => turn + 1} | prior_states]
  end

  # Assumes there is an empty space in this col
  def add_tile_to_col(game_objects, tile, y) do
    col = Enum.at(game_objects, y)

    x = last_empty_index(col)

    new_col = List.replace_at(col, x, tile)
    List.replace_at(game_objects, y, new_col)
  end

  defp last_empty_index(col) do
    reversed_index =
      Enum.find_index(Enum.reverse(col), fn
        %{"type" => "empty"} -> true
        _ -> false
      end)

    if is_nil(reversed_index) do
      nil
    else
      7 - reversed_index
    end
  end

  def handle_new_tile(%{"game_objects" => game_objects} = game_state, tile, y) do
    updated_game_objects = add_tile_to_col(game_objects, tile, y)

    new_game_state = %{game_state | "game_objects" => updated_game_objects}

    pop_tiles(new_game_state, [new_game_state])
  end

  @doc """
  Called when a new tile is dropped on a column.
  - Adds the new tile to a column.
    - Should do nothing if the column is full
  - Checks for popping tiles.
    - (Recursively) pops them, if there are any.
  - Checks if the game is ended by this placement.
  - Checks if the board is emptied by this placement.
  - Increments the turn count.
    - Increments the level, if necessary.
      - If so, checks / pops tiles.
  - Updates the score.
  - Generates a new tile to drop.
  """

  # returns a series of game states to animate.
  # game states are orderd [last ... first]
  def states_to_animate(
        %{
          "game_objects" => game_objects,
          "score" => score,
          "next_tile" => tile,
          "game_over" => false
        } =
          game_state,
        y
      ) do
    if is_nil(last_empty_index(Enum.at(game_objects, y))) do
      # Not possible to place a tile in this column
      [game_state]
    else
      [popped_state_with_tile | intermediate_states] =
        states = handle_new_tile(game_state, tile, y)

      # check for full clear
      if check_board_empty(popped_state_with_tile) do
        [next_state | additional_states] =
          increment_level(popped_state_with_tile, intermediate_states)

        [Map.put(next_state, "next_tile", random_tile()) | additional_states]
      else
        # check for game over
        if check_game_over(popped_state_with_tile) do
          [Map.put(popped_state_with_tile, "game_over", true) | intermediate_states]
        else
          [popped_incremented_state | additional_states] =
            states = increment_turn(popped_state_with_tile, intermediate_states)

          if check_game_over(popped_incremented_state) do
            [Map.put(popped_incremented_state, "game_over", true) | additional_states]
          else
            [Map.put(popped_incremented_state, "next_tile", random_tile()) | additional_states]
          end
        end
      end
    end
  end
end
