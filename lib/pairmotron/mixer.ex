defmodule Pairmotron.Mixer do
  @moduledoc """
  Mixes a provided list
  """

  @doc """
  Shuffles or applies the provided function to the provided list
  """
  @spec mixify(List.t, Fun.t) :: List.t
  def mixify(things, function \\ &Enum.shuffle/1) do
    things |> function.()
  end
end
