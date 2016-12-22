defmodule Pairmotron.Calendar do

  @doc """
  Returns true if the year and week passed in are the same week as the current
  date. Weeks start on Monday. The first week of the year is defined as the first
  week that contains a Thursday.
  """
  def same_week?(year, week, current_date) do
    {curr_year, curr_week} = Timex.iso_week(current_date)
    curr_year == year && curr_week == week
  end

  def past_week?(year, week, current_date) do
    {curr_year, curr_week} = Timex.iso_week(current_date)
    if curr_year == year do
      week < curr_week
    else
      year < curr_year
    end
  end

  def first_date_of_week(year, week) do
    Timex.from_iso_triplet({year, week, 1})
  end
end
