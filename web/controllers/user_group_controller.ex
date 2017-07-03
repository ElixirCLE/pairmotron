defmodule Pairmotron.UserGroupController do
  @moduledoc """
  Responsible for actions involving interacting with group membership directly.

  The :delete action deletes a UserGroup record which has the effect of
  removing a user from a group.
  """
  use Pairmotron.Web, :controller

  alias Pairmotron.UserGroup
  import Pairmotron.ControllerHelpers

  @spec edit(Plug.Conn.t, map()) :: Plug.Conn.t
  def edit(conn, %{"group_id" => group_id, "user_id" => user_id}) do
    user_group = user_id |> UserGroup.user_group_for_user_and_group(group_id) |> Repo.one
    user = conn.assigns.current_user
    logged_in_users_user_group = user.id |> UserGroup.user_group_for_user_and_group(group_id) |> Repo.one

    cond do
      is_nil(user_group) ->
        redirect_not_authorized(conn, group_path(conn, :show, group_id))
      is_nil(logged_in_users_user_group) ->
        redirect_not_authorized(conn, group_path(conn, :show, group_id))
      user_group.group.owner_id == user.id ->
        render_edit(conn, user_group)
      logged_in_users_user_group.is_admin ->
        render_edit(conn, user_group)
      user.is_admin ->
        render_edit(conn, user_group)
      true ->
        redirect_not_authorized(conn, group_path(conn, :show, group_id))
    end
  end

  defp render_edit(conn, user_group) do
    changeset = UserGroup.update_changeset(user_group)
    render(conn, "edit.html", changeset: changeset, user_group: user_group)
  end

  @spec update(Plug.Conn.t, map()) :: Plug.Conn.t
  def update(conn, %{"group_id" => group_id, "user_id" => user_id, "user_group" => user_group_params}) do
    user_group = user_id |> UserGroup.user_group_for_user_and_group(group_id) |> Repo.one
    user = conn.assigns.current_user
    logged_in_users_user_group = user.id |> UserGroup.user_group_for_user_and_group(group_id) |> Repo.one

    cond do
      is_nil(user_group) ->
        redirect_not_authorized(conn, group_path(conn, :show, group_id))
      is_nil(logged_in_users_user_group) ->
        redirect_not_authorized(conn, group_path(conn, :show, group_id))
      logged_in_users_user_group.is_admin ->
        update_user_group(conn, user_group, user_group_params)
      user_group.group.owner_id == user.id ->
        update_user_group(conn, user_group, user_group_params)
      user.is_admin ->
        update_user_group(conn, user_group, user_group_params)
      true ->
        redirect_not_authorized(conn, group_path(conn, :show, group_id))
    end
  end

  @spec update_user_group(Plug.Conn.t, Ecto.Changeset.t, Types.user_group) :: Plug.Conn.t
  defp update_user_group(conn, user_group, params) do
    changeset = UserGroup.update_changeset(user_group, params)
    case Repo.update(changeset) do
      {:ok, _user_group} ->
        conn
        |> put_flash(:info, "User's membership updated successfully.")
        |> redirect(to: group_path(conn, :show, user_group.group_id))
      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset, user_group: user_group)
    end
  end

  @doc """
  Deletes the specified UserGroup record if the logged in user is associated
  with the UserGroup or is the owner of the UserGroup's group association (or
  has sufficient privileges for that group). This removes that user from that
  group.
  """
  @spec delete(Plug.Conn.t, map()) :: Plug.Conn.t
  def delete(conn, %{"group_id" => group_id, "user_id" => user_id}) do
    user_group = user_group_for_user_and_group(user_id, group_id)
    current_user = conn.assigns.current_user
    current_user_group = user_group_for_user_and_group(current_user.id, group_id)
    cond do
      is_nil(user_group) ->
        conn
        |> put_flash(:error, "User's Group Membership record does not exist")
        |> redirect(to: pair_path(conn, :index))
      current_user.id == user_group.user_id ->
        delete_user_group_and_redirect(conn, user_group, profile_path(conn, :show))
      current_user.id == user_group.group.owner_id ->
        delete_user_group_and_redirect(conn, user_group, group_path(conn, :show, user_group.group))
      !is_nil(current_user_group) and current_user_group.is_admin ->
        delete_user_group_and_redirect(conn, user_group, group_path(conn, :show, user_group.group))
      true ->
        redirect_not_authorized(conn, group_path(conn, :show, user_group.group))
    end
  end

  @spec user_group_for_user_and_group(non_neg_integer(), non_neg_integer()) :: Types.user_group
  defp user_group_for_user_and_group(user_id, group_id) do
    user_id |> UserGroup.user_group_for_user_and_group(group_id) |> Repo.one
  end

  @spec delete_user_group_and_redirect(Plug.Conn.t, Types.user_group, binary()) :: Plug.Conn.t
  defp delete_user_group_and_redirect(conn, user_group, redirect_path) do
    Repo.delete!(user_group)

    conn
    |> put_flash(:info, "User removed from group successfully.")
    |> redirect(to: redirect_path)
  end
end
