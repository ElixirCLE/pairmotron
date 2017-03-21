defmodule Pairmotron.GroupPairView do
  @moduledoc false
  use Pairmotron.Web, :view
  import Pairmotron.PairView, only: [current_user_in_pair: 2]

  @spec past_week?(1..53, integer()) :: boolean()
  def past_week?(week, year) do
    Pairmotron.Calendar.past_week?(week, year, Timex.today)
  end

  @spec user_retro(%Plug.Conn{}) :: Types.retro
  def user_retro(conn) do
    conn.assigns[:current_user_retro_for_week]
  end
end
