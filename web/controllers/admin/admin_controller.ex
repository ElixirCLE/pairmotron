defmodule Pairmotron.AdminController do
  use Pairmotron.Web, :controller

  alias Pairmotron.Group

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
