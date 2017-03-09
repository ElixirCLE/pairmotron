defmodule Pairmotron.PairView do
  @moduledoc false
  use Pairmotron.Web, :view

  @spec current_user_in_pair(%Plug.Conn{}, Types.pair) :: boolean()
  def current_user_in_pair(conn, pair) do
    current_user = conn.assigns[:current_user]
    if is_nil(current_user) do
      false
    else
      pair.users
      |> Enum.map(fn u -> u.id end)
      |> Enum.any?(fn id -> id == current_user.id end)
    end
  end

  @spec user_retro(%Plug.Conn{}) :: Types.retro
  def user_retro(conn) do
    conn.assigns[:current_user_retro_for_week]
  end

  @spec past_week?(1..53, integer()) :: boolean()
  def past_week?(week, year) do
    Pairmotron.Calendar.past_week?(week, year, Timex.today)
  end
end
