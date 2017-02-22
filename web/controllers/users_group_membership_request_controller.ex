defmodule Pairmotron.UsersGroupMembershipRequestController do
  use Pairmotron.Web, :controller

  alias Pairmotron.{Group, GroupMembershipRequest, UserGroup}
  import Pairmotron.ControllerHelpers

  plug :load_resource, model: GroupMembershipRequest, only: [:update]

  def index(conn, _params) do
    group_membership_requests =
      conn.assigns.current_user
      |> assoc(:group_membership_requests)
      |> Repo.all
      |> Repo.preload(:group)
    render(conn, "index.html", group_membership_requests: group_membership_requests)
  end

  def create(conn, %{"group_membership_request" => group_membership_request_params}) do
    current_user = conn.assigns.current_user
    group_id = parameter_as_integer(group_membership_request_params, "group_id")

    cond do
      user_is_in_group?(current_user, group_id) ->
        redirect_and_flash_error(conn, "User already in group")
      true ->
        implicit_params = %{"user_id" => current_user.id, "initiated_by_user" => true}
        final_params = Map.merge(group_membership_request_params, implicit_params)
        changeset = GroupMembershipRequest.changeset(%GroupMembershipRequest{}, final_params)

        case Repo.insert(changeset) do
          {:ok, _group_membership_request} ->
            conn
            |> put_flash(:info, "Sent request to join group successfully.")
            |> redirect(to: users_group_membership_request_path(conn, :index))
          {:error, _changeset} ->
            redirect_and_flash_error(conn, "Error requesting group membership")
        end
    end
  end

  def update(conn, %{}) do
    group_membership_request = conn.assigns.group_membership_request
    user = conn.assigns.current_user

    cond do
      group_membership_request.user_id != user.id ->
        redirect_and_flash_error(conn, "Cannot accept invitation for other user")
      group_membership_request.initiated_by_user == true ->
        redirect_and_flash_error(conn, "Cannot accept invitation created by user")
      true ->
        user_group_changeset = UserGroup.changeset(%UserGroup{},
                                                   %{user_id: user.id, 
                                                     group_id: group_membership_request.group_id})

        transaction = update_transaction(group_membership_request, user_group_changeset)
        case Repo.transaction(transaction) do
          {:ok, _} ->
            conn
            |> put_flash(:info, "You have successfully joined group")
            |> redirect(to: users_group_membership_request_path(conn, :index))
          {:error, :group_membership_request, _, _} ->
            redirect_and_flash_error(conn, "Error removing invitation")
          {:error, :user_group, %{errors: [user_id_group_id: _]}, _} ->
            Repo.delete!(group_membership_request)
            redirect_and_flash_error(conn, "You are already in that group!")
          {:error, :user_group, _, _} ->
            redirect_and_flash_error(conn, "Error adding user to group")
        end
    end
  end

  defp user_is_in_group?(user, group_id) do
    group = Repo.get(Group, group_id)
    user = user |> Repo.preload(:groups)
    group in user.groups
  end

  defp redirect_and_flash_error(conn, message) do
    conn
    |> put_flash(:error, message)
    |> redirect(to: users_group_membership_request_path(conn, :index))
  end

  defp update_transaction(group_membership_request, user_group_changeset) do
    Ecto.Multi.new
    |> Ecto.Multi.delete(:group_membership_request, group_membership_request)
    |> Ecto.Multi.insert(:user_group, user_group_changeset)
  end
end
