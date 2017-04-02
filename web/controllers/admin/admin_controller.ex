defmodule Pairmotron.AdminController do
  use Pairmotron.Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
