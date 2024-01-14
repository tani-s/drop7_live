defmodule Drop7Web.GameLive do
  use Drop7LiveWeb, :live_view

  alias Drop7.Turn

  ### TODO:
  # animate popping
  # increment turns
  # scoring

  def render(assigns) do
    ~H"""
    <div class="game-container">
      <div class="modal" hidden={not @game_state.game_over}>
        <div class="modal-content">
          <h1>Game Over </h1>
          <button phx-click="start" class="btn">
            Play Again
          </button>
        </div>
      </div>
      <div class="next-tile">
        <div class="slot">
            <div class={"tile tile-" <> to_string(@game_state.next_tile.value)}>
              <%= @game_state.next_tile.value %>
            </div>
          </div>
      </div>
      <div class="game-board">
        <div :for={{row, index} <- Enum.with_index(@game_state.game_objects)}>
          <div :for={tile_or_slot <- row} phx-click={index}>
            <%= if tile_or_slot.type == :empty do %>
              <div class="slot empty-slot">
                <div class="tile tile-empty" />
              </div>
            <% end %>

            <%= if Map.get(tile_or_slot, :type) == :overflow do %>
              <%= if Map.get(tile_or_slot, :value) do %>
                <div class="slot game-over-slot">
                  <div class={"tile tile-" <> to_string(tile_or_slot.value)}>
                    <%= tile_or_slot.value %>
                  </div>
                </div>
              <% else %>
                <div class="overflow-slot">
                  <div class="tile tile-empty" />
                </div>
              <% end %>
            <% end %>

            <%= if tile_or_slot.type in [:egg, :cracked] do %>
              <div class="slot tile-slot">
                <div class={"tile tile-" <> to_string(tile_or_slot.type)}></div>
              </div>
            <% end %>

            <%= if tile_or_slot.type == :tile do %>
              <div class="slot tile-slot">
                <div class={"tile tile-" <> to_string(tile_or_slot.value)}>
                  <%= tile_or_slot.value %>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def start_game() do
    game_state = Drop7.InitGame.starting_tiles()
    |> IO.inspect()
    |> Drop7.TileRenderer.render_tile_map()
    |> tap(&Turn.print_board(&1, "rendered game objects"))
    |> Drop7.InitGame.to_game_state()
    |> Drop7.Turn.increment_level()
    |> tap(&Turn.print_board(&1, "level successfully incremented"))

    Map.put(game_state, :next_tile, Turn.random_tile)
  end

  def mount(_params, _session, socket) do
    game_state = start_game()

    socket = assign(socket, game_state: game_state)

    {:ok, socket}
  end

  def handle_event("start", _, socket) do
    game_state = start_game()

    socket = assign(socket, game_state: game_state)

    {:noreply, socket}
  end

  def handle_event("0", _, %{assigns: %{game_state: game_state}} = socket) do
    new_game_state = Turn.update_game_state(game_state, 0)

    {:noreply, assign(socket, game_state: new_game_state)}
  end


  def handle_event("1", _, %{assigns: %{game_state: game_state}} = socket) do
    new_game_state = Turn.update_game_state(game_state, 1)

    {:noreply, assign(socket, game_state: new_game_state)}
  end

  def handle_event("2", _, %{assigns: %{game_state: game_state}} = socket) do
    new_game_state = Turn.update_game_state(game_state, 2)

    {:noreply, assign(socket, game_state: new_game_state)}
  end

  def handle_event("3", _, %{assigns: %{game_state: game_state}} = socket) do
    new_game_state = Turn.update_game_state(game_state, 3)

    {:noreply, assign(socket, game_state: new_game_state)}
  end

  def handle_event("4", _, %{assigns: %{game_state: game_state}} = socket) do
    new_game_state = Turn.update_game_state(game_state, 4)

    {:noreply, assign(socket, game_state: new_game_state)}
  end

  def handle_event("5", _, %{assigns: %{game_state: game_state}} = socket) do
    new_game_state = Turn.update_game_state(game_state, 5)

    {:noreply, assign(socket, game_state: new_game_state)}
  end

  def handle_event("6", _, %{assigns: %{game_state: game_state}} = socket) do
    new_game_state = Turn.update_game_state(game_state, 6)

    {:noreply, assign(socket, game_state: new_game_state)}
  end

  # def handle_event(value, _, socket) do
  #   col = String.%{game_state: game_state}(value)


  #   new_game_state = Turn.update_game_state(game_state, col)

  # {:noreply, assign(socket, game_state: new_game_state)}
  # end

  # def handle_event("off", _, socket) do
  #   socket = assign(socket, :brightness, 0)
  #   {:noreply, socket}
  # end

  # def handle_event("on", _, socket) do
  #   socket = assign(socket, :brightness, 100)
  #   {:noreply, socket}
  # end
end
