defmodule Pairmotron.GroupView do
  use Pairmotron.Web, :view

  def current_user_can_edit_group?(conn, group) do
    user = conn.assigns.current_user
    user.id == group.owner_id or user.is_admin
  end

  def current_user_in_group?(conn, group) do
    conn.assigns.current_user.groups
    |> Enum.any?(&(&1.id == group.id))
  end
end
