defmodule Drop7Web.GameLive do
  use Drop7LiveWeb, :live_view

  alias Drop7.Turn
  alias Phoenix.LiveView.JS

  # TODO
  # Level + Max combo counts
  # high and average scores
  # Row and column highlighting
  # Dropping tile animation

  # Time in ms that schedules the game loop
  @tick 500

  def render(assigns) do
    ~H"""
    <div class="game">
      <div class="instructions">
        <h2 phx-click={JS.toggle(to: "#instructions")}>How to Play</h2>

        <p id="instructions">Drop tiles to build up rows and columns.

          When a tile is in a row or column of length equal to the tile's value, it will pop!

          New "egg" tiles will appear every five turns. Pop tiles adjacent to the eggs to reveal their values.

          Play till the board overflows. Good luck!</p>
      </div>

      <div class="score">
        <%= Number.Delimit.number_to_delimited(trunc(Map.get(@game_state, "score", 0))) %>
      </div>

      <div class="turn-tracker">
        <div class={"turn-#{Map.get(@game_state, "turn_count") > 4}"} />
        <div class={"turn-#{Map.get(@game_state, "turn_count") > 3}"} />
        <div class={"turn-#{Map.get(@game_state, "turn_count") > 2}"} />
        <div class={"turn-#{Map.get(@game_state, "turn_count") > 1}"} />
        <div class={"turn-#{Map.get(@game_state, "turn_count") > 0}"} />
      </div>

      <div class="game-container">
        <div class="animating-modal" hidden={not @animating} />
        <div class="modal" hidden={not Map.get(@game_state, "game_over", false)}>
          <div class="modal-content">
            <h1>Game Over</h1>

            <button phx-click="start" class="btn">
              Play Again
            </button>
          </div>
        </div>

        <div class="next-tile">
          <div class="slot" hidden={@animating}>
            <div
              class={"tile tile-" <> to_string(get_in(@game_state, ["next_tile", "value"]))}
              hidden={@animating}
            >
              <%= get_in(@game_state, ["next_tile", "value"]) %>
            </div>
          </div>
        </div>

        <div class="game-board">
          <div :for={{row, index} <- Enum.with_index(Map.get(@game_state, "game_objects", []))}>
            <div :for={tile_or_slot <- row} phx-click={index}>
              <%= if Map.get(tile_or_slot, "type") == "empty" do %>
                <div class="slot empty-slot">
                  <div class="tile tile-empty" />
                </div>
              <% end %>

              <%= if Map.get(tile_or_slot, "type") == "overflow" do %>
                <%= if Map.get(tile_or_slot, "value") do %>
                  <div class="slot game-over-slot">
                    <div class={"tile tile-" <> to_string(Map.get(tile_or_slot, "value"))}>
                      <%= Map.get(tile_or_slot, "value") %>
                    </div>
                  </div>
                <% else %>
                  <div class="slot overflow-slot">
                    <div class="tile tile-empty" />
                  </div>
                <% end %>
              <% end %>

              <%= if Map.get(tile_or_slot, "type") in ["egg", "cracked"] do %>
                <div class="slot tile-slot">
                  <div class={"tile tile-" <> to_string(Map.get(tile_or_slot, "type")) <> Map.get(tile_or_slot, "state", "")}>
                  </div>
                </div>
              <% end %>

              <%= if Map.get(tile_or_slot, "type") == "tile" do %>
                <div class="slot tile-slot">
                  <div class={"tile tile-" <> to_string(Map.get(tile_or_slot, "value")) <> Map.get(tile_or_slot, "state", "")}>
                    <%= Map.get(tile_or_slot, "value") %>
                  </div>

                  <div class="points" hidden={Map.get(tile_or_slot, "state", "") != " popping"}>
                    +<%= Number.Delimit.number_to_delimited(
                      Drop7Live.Score.combo(Map.get(@game_state, "combo"))
                    ) %>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def start_game() do
    game_state =
      Drop7.InitGame.starting_tiles()
      |> Drop7.TileRenderer.render_tile_map()
      # |> tap(&Turn.print_board(&1, "rendered game objects"))
      |> Drop7.InitGame.to_game_state()

    Map.put(game_state, "next_tile", Turn.random_tile())
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:game_state, start_game())
      |> assign(tick: @tick)
      |> assign(animating: false)

    {:ok, socket}
  end

  def handle_event(
        "get_localstorage",
        %{"game_state" => game_state, "scores" => scores} = params,
        socket
      )
      when not is_nil(game_state) do
    socket =
      socket
      |> assign(:game_state, game_state)
      |> assign(:scores, scores)

    {:noreply, socket}
  end

  def handle_event("get_localstorage", params, socket) do
    {:noreply, assign(socket, :game_state, start_game())}
  end

  def handle_event("start", _, socket) do
    game_state = start_game()

    {:noreply, assign(socket, :game_state, game_state)}
  end

  def handle_event(number, _, %{assigns: %{game_state: game_state}} = socket)
      when number in ["0", "1", "2", "3", "4", "5", "6"] do
    [new_game_state | _] =
      states = Turn.states_to_animate(%{game_state | "combo" => 1}, String.to_integer(number))

    Process.send_after(self(), {:set_game_state, new_game_state}, 0)

    if Map.get(new_game_state, "game_over") do
      Process.send_after(self(), {:set_scores, Map.get(new_game_state, "score")}, 0)
    end

    render_sequential_states(states, socket)
  end

  def handle_info({:render, []}, socket) do
    {:noreply, assign(socket, :animating, false)}
  end

  def handle_info({:render, [%{} = state | states]}, socket) do
    Process.send_after(self(), {:render, states}, @tick)

    {:noreply, assign(socket, :game_state, state)}
  end

  def handle_info({:set_game_state, game_state}, socket) do
    socket =
      push_event(socket, "store", %{
        key: "game_state",
        data: game_state
      })

    {:noreply, socket}
  end

  def handle_info({:set_scores, scores}, socket) do
    socket =
      push_event(socket, "store", %{
        key: "scores",
        data: scores
      })

    {:noreply, socket}
  end

  def render_sequential_states(states, socket) do
    Process.send_after(self(), {:render, Enum.reverse(states)}, 0)

    {:noreply, assign(socket, animating: true)}
  end
end
