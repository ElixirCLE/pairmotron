defmodule Pairmotron.GroupController do
  use Pairmotron.Web, :controller

  alias Pairmotron.{Group, GroupMembershipRequest}
  import Pairmotron.ControllerHelpers

  plug :load_and_authorize_resource, model: Group, only: [:edit, :update, :delete]

  def index(conn, _params) do
    groups = Group |> order_by(:name) |> Repo.all
    current_user = conn.assigns.current_user |> Repo.preload([:groups, :group_membership_requests])
    conn = conn |> Plug.Conn.assign(:current_user, current_user)
    render(conn, "index.html", groups: groups)
  end

  def show(conn, %{"id" => id}) do
    group = Repo.get!(Group, id) |> Repo.preload(:owner)
    invite_changeset = GroupMembershipRequest.changeset(%GroupMembershipRequest{}, %{group_id: id})
    current_user = conn.assigns.current_user |> Repo.preload([:groups, :group_membership_requests])
    conn = conn |> Plug.Conn.assign(:current_user, current_user)
    render(conn, "show.html", group: group, invite_changeset: invite_changeset)
  end

  def new(conn, _params) do
    changeset = Group.changeset(%Group{}, %{owner_id: conn.assigns.current_user.id})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"group" => group_params}) do
    owner_id = parameter_as_integer(group_params, "owner_id")
    owner = Repo.get(Pairmotron.User, owner_id)

    changeset = Group.changeset_for_create(%Group{}, group_params, [owner])

    case Repo.insert(changeset) do
      {:ok, _group} ->
        conn
        |> put_flash(:info, "Group created successfully.")
        |> redirect(to: group_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn = @authorized_conn, _params) do
    group = conn.assigns.group
    changeset = Group.changeset(group)
    render(conn, "edit.html", group: group, changeset: changeset)
  end
  def edit(conn, _params) do
    redirect_not_authorized(conn, group_path(conn, :index))
  end

  def update(conn = @authorized_conn, %{"group" => group_params}) do
    group = conn.assigns.group
    changeset = Group.changeset(group, group_params)

    case Repo.update(changeset) do
      {:ok, group} ->
        conn
        |> put_flash(:info, "Group updated successfully.")
        |> redirect(to: group_path(conn, :show, group))
      {:error, changeset} ->
        render(conn, "edit.html", group: group, changeset: changeset)
    end
  end
  def update(conn, _params) do
    redirect_not_authorized(conn, group_path(conn, :index))
  end

  def delete(conn = @authorized_conn, _params) do
    Repo.delete!(conn.assigns.group)
    conn
    |> put_flash(:info, "Group deleted successfully.")
    |> redirect(to: group_path(conn, :index))
  end
  def delete(conn, _params) do
    redirect_not_authorized(conn, group_path(conn, :index))
  end
end
