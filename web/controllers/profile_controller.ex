defmodule Pairmotron.ProfileController do
  @moduledoc """
  Handles interactions where Users can see and modify their own information.
  """
  use Pairmotron.Web, :controller

  alias Pairmotron.{User, UserGroup}

  @spec show(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def show(conn, _params) do
    current_user = conn.assigns.current_user |> Repo.preload([:groups, :group_membership_requests])
    user_groups = current_user.id |> UserGroup.user_groups_for_user_with_group |> Repo.all
    conn = conn |> Plug.Conn.assign(:current_user, current_user)
    render(conn, "show.html", user: current_user, user_groups: user_groups)
  end

  @spec edit(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def edit(conn, _params) do
    user = conn.assigns.current_user
    changeset = User.profile_changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  @spec update(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def update(conn, %{"user" => user_params}) do
    user = conn.assigns.current_user
    changeset = User.profile_changeset(user, user_params)
    case Repo.update(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Profile updated successfully.")
        |> redirect(to: profile_path(conn, :show))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

end
