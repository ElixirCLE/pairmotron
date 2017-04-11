defmodule Pairmotron.AdminController do
  use Pairmotron.Web, :controller

  @spec index(Plug.Conn.t, map()) :: Plug.Conn.t
  def index(conn, _params) do
    render(conn, "index.html")
  end
end
