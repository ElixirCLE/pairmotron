defmodule Pairmotron.Pairer do
  
  def generate_pairs(users) do
    users
    |> Enum.chunk(2, 2, [])
    |> unlonelify
  end

  def unlonelify(pairs) do
    pairs
    |> Enum.reverse
    |> friendify
    |> Enum.reverse
  end

  defp friendify( pairs = [ [_first, _second] | _rest] ), do: pairs

  defp friendify( [ [single] | [ pair | rest ] ] ) do
    [[single | pair] | rest ]
  end

  defp friendify(pairs), do: pairs

end
