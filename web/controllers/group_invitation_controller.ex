defmodule Pairmotron.GroupInvitationController do
  @moduledoc """
  Handles actions taken by group owners and group users with sufficient
  privileges involving GroupMembershipRequests.

  The :index action lists all current GroupMembershipRequests for a specific
  group, both created by that group, and created by users asking to join that
  group.

  The :create action creates a GroupMembershipRequest which is initiated by the
  group owner or a user in the group with sufficient privileges. In other
  words, this represents a group inviting a user to join the group

  The :update action accepts a user's  request to join a group. This invitation
  must have been created by that user. If this succeeds, the
  GroupMembershipRequest is deleted and that User is now part of this group.
  """
  use Pairmotron.Web, :controller

  alias Pairmotron.{Group, GroupMembershipRequest, User, UserGroup}
  alias Pairmotron.InviteDeleteHelper
  import Pairmotron.ControllerHelpers

  plug :load_resource, model: GroupMembershipRequest, only: [:update]

  @spec index(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def index(conn, %{"group_id" => group_id}) do
    group = Repo.get(Group, group_id)
    if group do
      if group.owner_id == conn.assigns.current_user.id do
        group = group |> Repo.preload([{:group_membership_requests, :user}])
        render(conn, "index.html", group_membership_requests: group.group_membership_requests, group: group)
      else
        redirect_not_authorized(conn, group_path(conn, :show, group))
      end
    else
      handle_resource_not_found(conn)
    end
  end

  @spec new(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def new(conn, %{"group_id" => group_id}) do
    group = Repo.get!(Group, group_id)
    if group.owner_id != conn.assigns.current_user.id do
      redirect_and_flash_error(conn, "You must be the owner of a group to invite user to that group", group_id)
    else
      changeset = GroupMembershipRequest.changeset(%GroupMembershipRequest{}, %{})
      invitable_users = invitable_users_for_select(group)
      render(conn, "new.html", changeset: changeset, group: group, invitable_users: invitable_users)
    end
  end

  @spec create(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def create(conn, %{"group_id" => group_id, "group_membership_request" => group_membership_request_params}) do
    current_user = conn.assigns.current_user

    {group_id_int, _} = Integer.parse(group_id)
    group = Group |> Repo.get!(group_id_int) |> Repo.preload(:users)

    user_id = parameter_as_integer(group_membership_request_params, "user_id")
    user = Repo.get!(User, user_id)

    if group.owner_id != current_user.id do
      redirect_and_flash_error(conn, "You must be the owner of a group to invite user to that group", group_id)
    else
      implicit_params = %{"initiated_by_user" => false, "group_id" => group_id}
      final_params = Map.merge(group_membership_request_params, implicit_params)
      changeset = GroupMembershipRequest.users_changeset(%GroupMembershipRequest{}, final_params, group)

      case Repo.insert(changeset) do
        {:ok, _group_membership_request} ->
          conn
          |> put_flash(:info, "Successfully invited #{user.name} to join #{group.name}.")
          |> redirect(to: group_invitation_path(conn, :index, group_id))
        {:error, changeset} ->
          invitable_users = invitable_users_for_select(group)
          render(conn, "new.html", changeset: changeset, group: group, invitable_users: invitable_users)
      end
    end
  end

  @spec invitable_users_for_select(Types.group) :: [{binary(), integer()}]
  defp invitable_users_for_select(group) do
    group
    |> User.users_not_in_group
    |> Repo.all
    |> Enum.map(&["#{&1.name}": &1.id])
    |> List.flatten
  end

  @spec update(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def update(conn, %{}) do
    group_membership_request = conn.assigns.group_membership_request |> Repo.preload([:user, :group])
    user = group_membership_request.user
    group = group_membership_request.group

    cond do
      group.owner_id != conn.assigns.current_user.id ->
        redirect_and_flash_error(conn, "You are not authorized to accept invitations for this group", group.id)
      group_membership_request.initiated_by_user == false ->
        redirect_and_flash_error(conn, "Cannot accept invitation created by group", group.id)
      true ->
        user_group_changeset = UserGroup.changeset(%UserGroup{}, %{user_id: user.id, group_id: group.id})

        transaction = update_transaction(group_membership_request, user_group_changeset)
        case Repo.transaction(transaction) do
          {:ok, _} ->
            conn
            |> put_flash(:info, "User successfully added to group")
            |> redirect(to: group_invitation_path(conn, :index, group.id))
          {:error, :group_membership_request, _, _} ->
            redirect_and_flash_error(conn, "Error removing invitation", group.id)
          {:error, :user_group, %{errors: [user_id_group_id: _]}, _} ->
            Repo.delete!(group_membership_request)
            redirect_and_flash_error(conn, "User is already in group!", group.id)
          {:error, :user_group, _, _} ->
            redirect_and_flash_error(conn, "Error adding user to group", group.id)
        end
    end
  end

  @spec delete(%Plug.Conn{}, map()) :: %Plug.Conn{}
  def delete(conn, %{"id" => id}) do
    group_membership_request = Repo.get!(GroupMembershipRequest, id) |> Repo.preload(:group)
    redirect_path = group_invitation_path(conn, :index, group_membership_request.group_id)
    InviteDeleteHelper.delete_invite(conn, group_membership_request, redirect_path)
  end

  @spec redirect_and_flash_error(%Plug.Conn{}, binary(), integer()) :: %Plug.Conn{}
  defp redirect_and_flash_error(conn, message, group_id) do
    conn
    |> put_flash(:error, message)
    |> redirect(to: group_invitation_path(conn, :index, group_id))
  end

  @spec update_transaction(Types.group_membership_request, %Ecto.Changeset{}) :: %Ecto.Multi{}
  defp update_transaction(group_membership_request, user_group_changeset) do
    Ecto.Multi.new
    |> Ecto.Multi.delete(:group_membership_request, group_membership_request)
    |> Ecto.Multi.insert(:user_group, user_group_changeset)
  end
end
