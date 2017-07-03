defmodule Pairmotron.AdminInvitationAcceptController do
  use Pairmotron.Web, :controller

  alias Pairmotron.{GroupMembershipRequest, User, UserGroup}

  @spec update(Plug.Conn.t, map()) :: Plug.Conn.t
  def update(conn, %{"user_id" => user_id, "group_membership_request_id" => group_membership_request_id}) do
    result = with {:ok, user} <- retrieve_user(user_id),
                  {:ok, group_membership_request} <- retrieve_group_membership_request(group_membership_request_id),
                  do: delete_invite_and_add_user_to_group(user, group_membership_request)

    case result do
      {:ok, :user_added_to_group} ->
        conn |> redirect_and_flash(:info, "User has been added to the group")
      {:ok, :user_already_in_group} ->
        conn |> redirect_and_flash(:info, "User was already in group. Invitation removed.")
      {:error, :user_not_found} ->
        conn |> redirect_and_flash(:error, "User could not be found.")
      {:error, :group_membership_request_not_found} ->
        conn |> redirect_and_flash(:info, "Invitation could not be found.")
    end
  end

  @spec delete_invite_and_add_user_to_group(Types.user, Types.group_membership_request) ::
    {:ok, :user_added_to_group | :user_already_in_group}
  defp delete_invite_and_add_user_to_group(user, group_membership_request) do
    group_id = group_membership_request.group_id
    case retrieve_user_group(user.id, group_id) do
      nil ->
        changeset = UserGroup.changeset(%UserGroup{}, %{user_id: user.id, group_id: group_id})
        multi = Ecto.Multi.new
          |> Ecto.Multi.delete(:group_membership_request, group_membership_request)
          |> Ecto.Multi.insert(:user_group, changeset)
        Repo.transaction(multi)
        {:ok, :user_added_to_group}
      _user_group ->
        Repo.delete!(group_membership_request)
        {:ok, :user_already_in_group}
    end
  end

  @spec retrieve_user(integer() | binary()) :: {:ok, Types.user} | {:error, :user_not_found}
  defp retrieve_user(user_id) do
    case Repo.get(User, user_id) do
      user = %User{} -> {:ok, user}
      _ -> {:error, :user_not_found}
    end
  end

  @spec retrieve_group_membership_request(integer() | binary()) ::
    {:ok, Types.group_membership_request} | {:error, :group_membership_request_not_found}
  defp retrieve_group_membership_request(group_membership_request_id) do
    case Repo.get(GroupMembershipRequest, group_membership_request_id) do
      group_membership_request = %GroupMembershipRequest{} -> {:ok, group_membership_request}
      _ -> {:error, :group_membership_request_not_found}
    end
  end

  @spec retrieve_user_group(integer(), integer()) :: Types.user_group | nil
  defp retrieve_user_group(user_id, group_id) do
    Repo.get_by(UserGroup, %{user_id: user_id, group_id: group_id})
  end

  @spec redirect_and_flash(Plug.Conn.t, atom(), String.t) :: Plug.Conn.t
  defp redirect_and_flash(conn, message_type, message) do
    conn
    |> put_flash(message_type, message)
    |> redirect(to: admin_group_membership_request_path(conn, :index))
  end
end
