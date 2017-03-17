defmodule Pairmotron.UserGroupController do
  @moduledoc """
  Responsible for actions involving interacting with group membership directly.

  The :delete action deletes a UserGroup record which has the effect of
  removing a user from a group.
  """
  use Pairmotron.Web, :controller

  alias Pairmotron.UserGroup
  import Pairmotron.ControllerHelpers

  @doc """
  Deletes the specified UserGroup record if the logged in user is associated
  with the UserGroup or is the owner of the UserGroup's group association (or
  has sufficient privileges for that group). This removes that user from that
  group.
  """
  @spec delete(Plug.Conn.t, map()) :: Plug.Conn.t
  def delete(conn, %{"id" => id}) do
    user_group = UserGroup |> Repo.get!(id) |> Repo.preload(:group)

    current_user = conn.assigns.current_user
    cond do
      current_user.id == user_group.user_id ->
        delete_user_group_and_redirect(conn, user_group, profile_path(conn, :show))
      current_user.id == user_group.group.owner_id ->
        delete_user_group_and_redirect(conn, user_group, group_path(conn, :show, user_group.group))
      true ->
        redirect_not_authorized(conn, group_path(conn, :show, user_group.group))
    end
  end

  @spec delete_user_group_and_redirect(Plug.Conn.t, Types.user_group, binary()) :: Plug.Conn.t
  defp delete_user_group_and_redirect(conn, user_group, redirect_path) do
    Repo.delete!(user_group)

    conn
    |> put_flash(:info, "User removed from group successfully.")
    |> redirect(to: redirect_path)
  end
end
