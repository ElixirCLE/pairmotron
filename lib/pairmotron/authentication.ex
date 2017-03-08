defmodule Pairmotron.Authentication do
  @moduledoc """
  Helper module for Pairmotron authentication. Sole responsibility is returning
  the current_user from the Plug.Conn if it is present or attempting to
  retrieve the current_user from the Guardian JWT.
  """
  alias Pairmotron.Types

  @doc """
  Returns the current user that is present on the Plug.Conn, or attempts to
  retrieve the current user from the guardian JWT. If neither is retrieves,
  this returns nil.
  """
  @spec current_user(%Plug.Conn{}) :: Types.user | nil
  def current_user(conn), do: conn.assigns[:current_user] || Guardian.Plug.current_resource(conn)
end
