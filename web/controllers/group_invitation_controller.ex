defmodule Pairmotron.GroupInvitationController do
  use Pairmotron.Web, :controller

  alias Pairmotron.{Group, GroupMembershipRequest, UserGroup}
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

  def create(conn, %{"group_membership_request" => group_membership_request_params}) do
    conn
  end

  def update(conn, %{"group_membership_request" => _params}) do
    conn
  end
end
