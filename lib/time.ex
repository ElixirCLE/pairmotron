defmodule Pairmotron.Time do

  @doc """
  Returns true if the year and week passed in are the same week as the current
  date. Weeks start on Monday. The first week of the year is defined as the first
  week that contains a Thursday.
  """
  def same_week?(year, week, current_date) do
    {curr_year, curr_week} = Timex.iso_week(current_date)
    curr_year == year && curr_week == week
  end

end
