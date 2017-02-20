defmodule Pairmotron.GroupView do
  use Pairmotron.Web, :view

  def user_can_edit_group?(user, group) do
    user.id == group.owner_id or user.is_admin
  end
end
