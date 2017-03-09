defmodule Pairmotron.RegistrationController do
  @moduledoc """
  Handles Users registering for accounts and also logging in when they succeed
  at doing so.
  """
  use Pairmotron.Web, :controller

  alias Pairmotron.User

  plug :scrub_params, "user" when action in [:create]

  @spec new(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def new(conn, _params) do
    render conn, changeset: User.profile_changeset(%User{})
  end

  @spec create(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Successfully registered and logged in")
        |> Guardian.Plug.sign_in(user)
        |> redirect(to: profile_path(conn, :show))
      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
    end
  end
end
