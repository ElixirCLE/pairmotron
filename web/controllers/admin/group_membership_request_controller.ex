defmodule Pairmotron.AdminGroupMembershipRequestController do
  use Pairmotron.Web, :controller

  alias Pairmotron.GroupMembershipRequest

  def index(conn, _params) do
    group_membership_requests = Repo.all(GroupMembershipRequest) |> Repo.preload([:group, :user])
    render(conn, "index.html", group_membership_requests: group_membership_requests)
  end

  def new(conn, _params) do
    changeset = GroupMembershipRequest.changeset(%GroupMembershipRequest{})
    groups = Repo.all(Pairmotron.Group)
    users = Repo.all(Pairmotron.User)
    render(conn, "new.html", changeset: changeset, groups: groups, users: users)
  end

  def create(conn, %{"group_membership_request" => group_membership_request_params}) do
    changeset = GroupMembershipRequest.changeset(%GroupMembershipRequest{}, group_membership_request_params)
    groups = Repo.all(Pairmotron.Group)
    users = Repo.all(Pairmotron.User)

    case Repo.insert(changeset) do
      {:ok, _group_membership_request} ->
        conn
        |> put_flash(:info, "GroupMembershipRequest created successfully.")
        |> redirect(to: admin_group_membership_request_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, groups: groups, users: users)
    end
  end

  def show(conn, %{"id" => id}) do
    group_membership_request = Repo.get!(GroupMembershipRequest, id) |> Repo.preload([:group, :user])
    render(conn, "show.html", group_membership_request: group_membership_request)
  end

  def edit(conn, %{"id" => id}) do
    group_membership_request = Repo.get!(GroupMembershipRequest, id)
    changeset = GroupMembershipRequest.changeset(group_membership_request)
    groups = Repo.all(Pairmotron.Group)
    users = Repo.all(Pairmotron.User)
    render(conn, "edit.html", group_membership_request: group_membership_request, changeset: changeset, groups: groups, users: users)
  end

  def update(conn, %{"id" => id, "group_membership_request" => group_membership_request_params}) do
    group_membership_request = Repo.get!(GroupMembershipRequest, id)
    changeset = GroupMembershipRequest.changeset(group_membership_request, group_membership_request_params)
    groups = Repo.all(Pairmotron.Group)
    users = Repo.all(Pairmotron.User)

    case Repo.update(changeset) do
      {:ok, group_membership_request} ->
        conn
        |> put_flash(:info, "GroupMembershipRequest updated successfully.")
        |> redirect(to: admin_group_membership_request_path(conn, :show, group_membership_request))
      {:error, changeset} ->
        render(conn, "edit.html", group_membership_request: group_membership_request, changeset: changeset, groups: groups, users: users)
    end
  end

  def delete(conn, %{"id" => id}) do
    group_membership_request = Repo.get!(GroupMembershipRequest, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(group_membership_request)

    conn
    |> put_flash(:info, "GroupMembershipRequest deleted successfully.")
    |> redirect(to: admin_group_membership_request_path(conn, :index))
  end
end
