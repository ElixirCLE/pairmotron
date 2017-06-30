defmodule Pairmotron.AdminGroupMembershipRequestController do
  use Pairmotron.Web, :controller

  alias Pairmotron.{Group, GroupMembershipRequest}

  import Pairmotron.ControllerHelpers

  @spec index(Plug.Conn.t, map()) :: Plug.Conn.t
  def index(conn, _params) do
    group_membership_requests = GroupMembershipRequest |> Repo.all |> Repo.preload([:group, :user])
    render(conn, "index.html", group_membership_requests: group_membership_requests)
  end

  @spec new(Plug.Conn.t, map()) :: Plug.Conn.t
  def new(conn, _params) do
    changeset = GroupMembershipRequest.changeset(%GroupMembershipRequest{})
    groups = Repo.all(Pairmotron.Group)
      |> Enum.sort(&(String.downcase(&1.name) <= String.downcase(&2.name)))
    users = Repo.all(Pairmotron.User)
      |> Enum.sort(&(String.downcase(&1.name) <= String.downcase(&2.name)))
    render(conn, "new.html", changeset: changeset, groups: groups, users: users)
  end

  @spec create(Plug.Conn.t, map()) :: Plug.Conn.t
  def create(conn, %{"group_membership_request" => group_membership_request_params}) do
    group_id = parameter_as_integer(group_membership_request_params, "group_id")
    group = group_id |> Group.group_with_users |> Repo.one
    changeset = GroupMembershipRequest.users_changeset(%GroupMembershipRequest{}, group_membership_request_params, group)
    groups = Repo.all(Pairmotron.Group)
      |> Enum.sort(&(String.downcase(&1.name) <= String.downcase(&2.name)))
    users = Repo.all(Pairmotron.User)
      |> Enum.sort(&(String.downcase(&1.name) <= String.downcase(&2.name)))

    case Repo.insert(changeset) do
      {:ok, _group_membership_request} ->
        conn
        |> put_flash(:info, "GroupMembershipRequest created successfully.")
        |> redirect(to: admin_group_membership_request_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, groups: groups, users: users)
    end
  end

  @spec show(Plug.Conn.t, map()) :: Plug.Conn.t
  def show(conn, %{"id" => id}) do
    group_membership_request = GroupMembershipRequest |> Repo.get!(id) |> Repo.preload([:group, :user])
    render(conn, "show.html", group_membership_request: group_membership_request)
  end

  @spec edit(Plug.Conn.t, map()) :: Plug.Conn.t
  def edit(conn, %{"id" => id}) do
    group_membership_request = Repo.get!(GroupMembershipRequest, id)
    changeset = GroupMembershipRequest.changeset(group_membership_request)
    groups = Repo.all(Pairmotron.Group)
      |> Enum.sort(&(String.downcase(&1.name) <= String.downcase(&2.name)))
    users = Repo.all(Pairmotron.User)
      |> Enum.sort(&(String.downcase(&1.name) <= String.downcase(&2.name)))
    render(conn, "edit.html", group_membership_request: group_membership_request, changeset: changeset, groups: groups, users: users)
  end

  @spec update(Plug.Conn.t, map()) :: Plug.Conn.t
  def update(conn, %{"id" => id, "group_membership_request" => group_membership_request_params}) do
    group_membership_request = Repo.get!(GroupMembershipRequest, id)
    changeset = GroupMembershipRequest.users_changeset(group_membership_request, group_membership_request_params)
    groups = Repo.all(Pairmotron.Group)
      |> Enum.sort(&(String.downcase(&1.name) <= String.downcase(&2.name)))
    users = Repo.all(Pairmotron.User)
      |> Enum.sort(&(String.downcase(&1.name) <= String.downcase(&2.name)))

    case Repo.update(changeset) do
      {:ok, group_membership_request} ->
        conn
        |> put_flash(:info, "GroupMembershipRequest updated successfully.")
        |> redirect(to: admin_group_membership_request_path(conn, :show, group_membership_request))
      {:error, changeset} ->
        render(conn, "edit.html", group_membership_request: group_membership_request, changeset: changeset, groups: groups, users: users)
    end
  end

  @spec delete(Plug.Conn.t, map()) :: Plug.Conn.t
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
