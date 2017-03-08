defmodule Pairmotron.Mixer do

  def mixify(things, week \\ 1)
  def mixify([], _week), do: []
  def mixify(things, week) do
    single = things
      |> Enum.at(rem(week, length(things)))
    remainder = things
      |> List.delete(single)
    [single | mixify(remainder, week)]
  end
end
