defmodule Pairmotron.PairRetroView do
  @moduledoc false
  use Pairmotron.Web, :view

  @spec format_date(nil | Date.t) :: binary()
  def format_date(nil), do: ""
  def format_date(date), do: Ecto.Date.to_string(date)

  @spec format_project(nil | Types.project) :: binary()
  def format_project(nil), do: "(none)"
  def format_project(%Pairmotron.Project{name: name}), do: name
end
