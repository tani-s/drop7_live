defmodule Drop7Live.Score do
  @moduledoc """
  Functions for calculating scores.
  """

  # cubic function for generating combo scores
  # 7, 39, 109, 224, 391...
  def combo(n) do
    a = 7 / 6
    b = 12
    c = -73 / 6
    d = 6

    a * :math.pow(n, 3) + b * :math.pow(n, 2) + c * n + d
  end
end
