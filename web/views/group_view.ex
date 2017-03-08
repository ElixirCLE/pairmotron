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

  def current_user_has_requested_membership_to_group?(conn, group) do
    conn.assigns.current_user.group_membership_requests
    |> Enum.any?(&(&1.group_id == group.id and &1.initiated_by_user))
  end

  def current_user_has_been_invited_by_group?(conn, group) do
    conn.assigns.current_user.group_membership_requests
    |> Enum.any?(&(&1.group_id == group.id and not &1.initiated_by_user))
  end

  def current_user_group_membership_request_for_group(conn, group) do
    conn.assigns.current_user.group_membership_requests
    |> Enum.find(&(&1.group_id == group.id and not &1.initiated_by_user))
  end

  def truncate(nil, _), do: nil
  def truncate(string, len) do
    if String.length(string) > len do
      String.slice(string, 0, len) <> "..."
    else
      string
    end
  end
end
