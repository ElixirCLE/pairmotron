defmodule Pairmotron.ProjectView do
  use Pairmotron.Web, :view

  def groups_for_select(conn) do
    case conn.assigns[:projects] do
      nil -> []
      projects ->
        projects
        |> Enum.map(&["#{&1.name}": &1.id])
        |> List.flatten
    end
  end
end
