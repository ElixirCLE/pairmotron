defmodule Pairmotron.InviteDeleteHelper do
  @moduledoc """
  Helper library used to reduce duplication between the :delete actions of the
  UsersGroupMembershipRequestController and the GroupInvitationController.
  """
  use Pairmotron.Web, :controller

  @doc """
  Deletes an invitation and redirects to the proper path.

  Created to reduce duplication between the :delete actions in the
  UsersGroupMembershipRequestController and the GroupInvitationController,
  since the logic is identical, except for the redirect path.
  """
  @spec delete_invite(Plug.Conn.t, Types.group_membership_request, binary()) :: Plug.Conn.t
  def delete_invite(conn, group_membership_request, redirect_path) do
    current_user = conn.assigns.current_user

    if user_can_delete_invite(current_user, group_membership_request) do
      Repo.delete!(group_membership_request)
      conn
      |> put_flash(:info, "Group Invite deleted successfully.")
      |> redirect(to: redirect_path)
    else
      redirect_and_flash_error(conn, "You cannot delete that group invitation", redirect_path)
    end
  end

  @spec redirect_and_flash_error(%Plug.Conn{}, binary(), binary()) :: %Plug.Conn{}
  defp redirect_and_flash_error(conn, message, redirect_path) do
    conn
    |> put_flash(:error, message)
    |> redirect(to: redirect_path)
  end

  @spec user_can_delete_invite(Types.user, Types.group_membership_request) :: boolean()
  defp user_can_delete_invite(user, group_membership_request) do
    user.id in [group_membership_request.user_id, group_membership_request.group.owner_id]
  end
end
