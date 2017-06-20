defmodule Pairmotron.Interval do
  defstruct from: nil, until: nil, left_open: false, right_open: true

  def new(options \\ []) do
    from = Keyword.get(options, :from, nil)
    until = Keyword.get(options, :until, nil)
    left_open = Keyword.get(options, :left_open, false)
    right_open = Keyword.get(options, :right_open, true)
    new(from, until, left_open, right_open)
  end

  def new(from, until, left_open \\ false, right_open \\ true) do
    %__MODULE__{from: from |> convert_to_erl_date(),
                until: until |> convert_to_erl_date(),
                left_open: left_open,
                right_open: right_open}
  end

  defp convert_to_erl_date(nil), do: nil
  defp convert_to_erl_date(date = {_, _, _}), do: date
  defp convert_to_erl_date({date = {_, _, _}, {_, _, _}}), do: date
  defp convert_to_erl_date(date = %Date{}), do: date |> Date.to_erl()
  defp convert_to_erl_date(date = %DateTime{}), do: date |> Timex.to_date()
end
