defmodule Pairmotron.GroupPairView do
  @moduledoc false
  use Pairmotron.Web, :view
  import Pairmotron.PairView, only: [current_user_in_pair: 2, user_retro: 1]

  @spec past_week?(1..53, integer()) :: boolean()
  def past_week?(week, year) do
    Pairmotron.Calendar.past_week?(week, year, Timex.today)
  end
end
