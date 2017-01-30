defmodule Pairmotron.RegistrationControllerTest do
  use Pairmotron.ConnCase

  alias Pairmotron.User

  @valid_reg_attrs %{email: "email", name: "name", password: "password", password_confirmation: "password"}
  @invalid_attrs %{}

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, registration_path(conn, :new)
    assert html_response(conn, 200) =~ "Registration"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, registration_path(conn, :create), user: @valid_reg_attrs
    assert redirected_to(conn) == pair_path(conn, :index)
    assert Repo.get_by(User, %{email: "email", name: "name"})
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, registration_path(conn, :create), user: @invalid_attrs
    assert html_response(conn, 200) =~ "Registration"
    assert html_response(conn, 200) =~ "There was a problem registering your account"
  end
end
