defmodule Pairmotron.Authentication do

 def current_user(conn), do: conn.assigns[:current_user] || Guardian.Plug.current_resource(conn)
end
