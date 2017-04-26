defmodule Pairmotron.Daterange do
   @behaviour Ecto.Type

   @moduledoc """
   A Postgres type for daterange based around Timex.Interval.
   See https://www.postgresql.org/docs/9.6/static/rangetypes.html for more information.
   Based off https://gist.github.com/h0lyalg0rithm/54fdfb02fd2cf8e8196b71d832c49b1b
   """

   alias Timex.Interval

   @doc "To this custom type"
   def cast(interval = %Interval{}) do
     {:ok, interval}
   end
   def cast([lower, upper]) do
     {:ok, Interval.new(from: lower, until: upper)}
   end
   def cast(_), do: :error

   @doc "From this custom type to Postgres"
   def dump(interval = %Interval{}) do
     {:ok, %Postgrex.Range{lower: interval.from,
                           upper: interval.until,
                           upper_inclusive: ! interval.right_open,
                           lower_inclusive: ! interval.left_open}}
   end
   def dump(_), do: :error

   @doc "From Postgres to this custom type"
   def load(%Postgrex.Range{lower: from, upper: until, upper_inclusive: right_open, lower_inclusive: left_open}) do
     {:ok, Interval.new(from: from,
                        until: until,
                        right_open: ! right_open,
                        left_open: ! left_open)}
   end

   @doc "The schema type in Postgres"
   @spec type() :: :daterange
   def type, do: :daterange
end
