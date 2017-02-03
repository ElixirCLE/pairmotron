defmodule Pairmotron.ProjectView do
  use Pairmotron.Web, :view

  def format_group(nil), do: "(none)"
  def format_group(%Pairmotron.Group{name: name}), do: name

  def groups_for_select(conn) do
    case conn.assigns[:groups] do
      nil -> []
      groups ->
        groups
        |> Enum.map(&["#{&1.name}": &1.id])
        |> List.flatten
    end
  end
end
