defmodule Pairmotron.Calendar do
  @moduledoc """
  A Collection of functions for interacting with dates that are specific in use
  to Pairmotron.
  """

  @doc """
  Returns true if the year and week passed in are the same week as the current
  date. Weeks start on Monday. The first week of the year is defined as the
  first week that contains a Thursday.
  """
  @spec same_week?(integer(), 1..53, %Date{}) :: boolean() 
  def same_week?(year, week, current_date) do
    {curr_year, curr_week} = Timex.iso_week(current_date)
    curr_year == year && curr_week == week
  end

  @doc """
  Returns true if the year and week passed in are in a week that is earlier
  than the passed in current_date.  Returns false if the year and week are the
  same iso week or are in a later iso week than the current_date.
  """
  @spec past_week?(integer(), 1..53, %Date{}) :: boolean()
  def past_week?(year, week, current_date) do
    {curr_year, curr_week} = Timex.iso_week(current_date)
    if curr_year == year do
      week < curr_week
    else
      year < curr_year
    end
  end

  @doc """
  Returns the date of the monday of the passed in year and iso week.
  """
  @spec first_date_of_week(integer(), 1..53) :: %Date{}
  def first_date_of_week(year, week) do
    Timex.from_iso_triplet({year, week, 1})
  end
end
