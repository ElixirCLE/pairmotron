defmodule Pairmotron.GroupController do
  use Pairmotron.Web, :controller

  alias Pairmotron.Group
  import Pairmotron.ControllerHelpers

  plug :load_and_authorize_resource, model: Group, only: [:edit, :update, :delete]

  def index(conn, _params) do
    groups = Repo.all(Group)
    render(conn, "index.html", groups: groups)
  end

  def new(conn, _params) do
    changeset = Group.changeset(%Group{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"group" => group_params}) do
    changeset = Group.changeset(%Group{}, group_params)

    case Repo.insert(changeset) do
      {:ok, _group} ->
        conn
        |> put_flash(:info, "Group created successfully.")
        |> redirect(to: group_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    group = Repo.get!(Group, id)
    render(conn, "show.html", group: group)
  end

  def edit(conn, %{"id" => _id}) do
    if conn.assigns.authorized do
      group = conn.assigns.group
      changeset = Group.changeset(group)
      render(conn, "edit.html", group: group, changeset: changeset)
    else
      redirect_not_authorized(conn, group_path(conn, :index))
    end
  end

  def update(conn, %{"id" => _id, "group" => group_params}) do
    if conn.assigns.authorized do
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
    else
      redirect_not_authorized(conn, group_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => _id}) do
    if conn.assigns.authorized do
      Repo.delete!(conn.assigns.group)

      conn
      |> put_flash(:info, "Group deleted successfully.")
      |> redirect(to: group_path(conn, :index))
    else
      redirect_not_authorized(conn, group_path(conn, :index))
    end
  end
end
