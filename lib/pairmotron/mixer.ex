defmodule Pairmotron.Mixer do

  def mixify(things) do
    things |> Enum.shuffle
  end
end
