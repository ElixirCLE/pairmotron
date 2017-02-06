defmodule Pairmotron.UsersGroupMembershipRequestController do
  use Pairmotron.Web, :controller

  alias Pairmotron.{Group, GroupMembershipRequest, User}
  import Pairmotron.ControllerHelpers

  def index(conn, _params) do
    group_membership_requests =
      conn.assigns.current_user
      |> assoc(:group_membership_requests)
      |> Repo.all
      |> Repo.preload(:group)
    render(conn, "index.html", group_membership_requests: group_membership_requests)
  end
end
