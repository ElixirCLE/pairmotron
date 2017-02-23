defmodule Pairmotron.LayoutView do
  use Pairmotron.Web, :view

  def logged_in?(conn) do
    !!conn.assigns[:current_user]
  end
end
