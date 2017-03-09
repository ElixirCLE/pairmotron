defmodule Pairmotron.LayoutView do
  @moduledoc false
  use Pairmotron.Web, :view

  @spec logged_in?(%Plug.Conn{}) :: boolean()
  def logged_in?(conn) do
    !!conn.assigns[:current_user]
  end
end
