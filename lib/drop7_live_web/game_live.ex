defmodule Drop7Web.GameLive do
  use Drop7LiveWeb, :live_view

  alias Drop7.Turn

  ### TODO:
  # animate popping
  # increment turns
  # scoring
  # Time in ms that schedules the game loop
  @tick 500

  def render(assigns) do
    ~H"""
    <div class="turn-tracker">
      <div class={"turn-#{@game_state.turn_count > 4}"} />
      <div class={"turn-#{@game_state.turn_count > 3}"} />
      <div class={"turn-#{@game_state.turn_count > 2}"} />
      <div class={"turn-#{@game_state.turn_count > 1}"} />
      <div class={"turn-#{@game_state.turn_count > 0}"} />
    </div>
    <div class="game-container">
      <div class="animating-modal" hidden={not @animating} />
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
            <div class={"tile tile-" <> to_string(@game_state.next_tile.value)} hidden={@animating}>
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
                <div class={"tile tile-" <> to_string(tile_or_slot.type) <> Map.get(tile_or_slot, :state, "")}>
                </div>
              </div>
            <% end %>

            <%= if tile_or_slot.type == :tile do %>
              <div class="slot tile-slot">
                <div class={"tile tile-" <> to_string(tile_or_slot.value) <> Map.get(tile_or_slot, :state, "")}>
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

    Map.put(game_state, :next_tile, Turn.random_tile)
  end

  def mount(_params, _session, socket) do
    game_state = start_game()

    socket = socket
    |> assign(game_state: game_state)
    |> assign(tick: @tick)
    |> assign(animating: false)

    {:ok, socket}
  end

  def handle_info({:render, []}, socket) do
    {:noreply, assign(socket, animating: false)}
  end

  def handle_info({:render, [%{} = state | states]}, socket) do
    Process.send_after(self(), {:render, states}, @tick)

    {:noreply, assign(socket, game_state: state)}
  end

  def render_sequential_states(states, socket) do
    Process.send_after(self(), {:render, Enum.reverse(states)}, 0)

    {:noreply, assign(socket, animating: true)}
  end

  def handle_event("start", _, socket) do
    game_state = start_game()

    socket = assign(socket, game_state: game_state)

    {:noreply, socket}
  end

  def handle_event("0", _, %{assigns: %{game_state: game_state}} = socket) do
    [new_game_state | _]= states = Turn.states_to_animate(game_state, 0)

    render_sequential_states(states, socket)
    # {:noreply, assign(socket, game_state: new_game_state)}
  end


  def handle_event("1", _, %{assigns: %{game_state: game_state}} = socket) do
    [new_game_state | _]= states = Turn.states_to_animate(game_state, 1)

    render_sequential_states(states, socket)
    # {:noreply, assign(socket, game_state: new_game_state)}
  end

  def handle_event("2", _, %{assigns: %{game_state: game_state}} = socket) do
    [new_game_state | _]= states = Turn.states_to_animate(game_state, 2)

    render_sequential_states(states, socket)
    # {:noreply, assign(socket, game_state: new_game_state)}
  end

  def handle_event("3", _, %{assigns: %{game_state: game_state}} = socket) do
    [new_game_state | _]= states = Turn.states_to_animate(game_state, 3)

    render_sequential_states(states, socket)
    # {:noreply, assign(socket, game_state: new_game_state)}
  end

  def handle_event("4", _, %{assigns: %{game_state: game_state}} = socket) do
    [new_game_state | _]= states = Turn.states_to_animate(game_state, 4)

    render_sequential_states(states, socket)
    # {:noreply, assign(socket, game_state: new_game_state)}
  end

  def handle_event("5", _, %{assigns: %{game_state: game_state}} = socket) do
    [new_game_state | _]= states = Turn.states_to_animate(game_state, 5)

    render_sequential_states(states, socket)
    # {:noreply, assign(socket, game_state: new_game_state)}
  end

  def handle_event("6", _, %{assigns: %{game_state: game_state}} = socket) do
    [new_game_state | _]= states = Turn.states_to_animate(game_state, 6)

    render_sequential_states(states, socket)
    # {:noreply, assign(socket, game_state: new_game_state)}
  end
end
