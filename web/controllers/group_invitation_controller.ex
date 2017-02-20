defmodule Pairmotron.GroupInvitationController do
  use Pairmotron.Web, :controller

  alias Pairmotron.{Group, GroupMembershipRequest, User, UserGroup}
  import Pairmotron.ControllerHelpers

  def index(conn, %{"group_id" => group_id}) do
    group = Repo.get(Group, group_id)
    if group do
      group = group |> Repo.preload([{:group_membership_requests, :user}])
      if group.owner_id == conn.assigns.current_user.id do
        render(conn, "index.html", group_membership_requests: group.group_membership_requests)
      else
        redirect_not_authorized(conn, group_path(conn, :show, group))
      end
    else
      handle_resource_not_found(conn)
    end
  end

  def create(conn, %{"group_id" => group_id, "group_membership_request" => group_membership_request_params}) do
    current_user = conn.assigns.current_user

    {group_id_int, _} = Integer.parse(group_id)
    group = preloaded_group_or_nil(group_id_int)

    user_id = parameter_as_integer(group_membership_request_params, "user_id")
    user = Repo.get(User, user_id)

    cond do
      is_nil(user) ->
        handle_resource_not_found(conn)
      is_nil(group) ->
        handle_resource_not_found(conn)
      group.owner_id != current_user.id ->
        redirect_and_flash_error(conn, "You must be the owner of a group to invite user to that group", group_id)
      user in group.users ->
        redirect_and_flash_error(conn, "Cannot invite user that is already in group", group_id)
      true ->
        implicit_params = %{"initiated_by_user" => false, "group_id" => group_id}
        final_params = Map.merge(group_membership_request_params, implicit_params)
        changeset = GroupMembershipRequest.changeset(%GroupMembershipRequest{}, final_params)

        case Repo.insert(changeset) do
          {:ok, _group_membership_request} ->
            #Repo.all(GroupMembershipRequest) |> IO.inspect
            conn
            |> put_flash(:info, "Sent invitation to join group successfully.")
            |> redirect(to: group_invitation_path(conn, :index, group_id))
          {:error, _changeset} ->
            redirect_and_flash_error(conn, "Error inviting to group", group_id)
        end
    end
  end

  def update(conn, %{"group_membership_request" => _params}) do
    conn
  end

  defp preloaded_group_or_nil(group_id) do
    group = case Repo.get(Group, group_id) do
      nil -> nil
      group -> Repo.preload(group, :users)
    end
  end

  defp redirect_and_flash_error(conn, message, group_id) do
    conn
    |> put_flash(:error, message)
    |> redirect(to: group_invitation_path(conn, :index, group_id))
  end
end
