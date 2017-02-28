defmodule Pairmotron.LoginHelper do
  import Pairmotron.Factory
  import Pairmotron.TestHelper, only: [log_in: 2]
  import Phoenix.ConnTest

  def login_user() do
    user = insert(:user)
    conn = build_conn() |> log_in(user)
    {:ok, [conn: conn, logged_in_user: user]}
  end
end
