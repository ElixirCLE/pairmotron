defmodule Pairmotron.ExAdmin.GroupMembershipRequest do
  @moduledoc false
  use ExAdmin.Register

  register_resource Pairmotron.GroupMembershipRequest do
    filter [:initiated_by_user]
    index do
      selectable_column()

      column :id
      column :user, fn(group_membership_request) ->
        Phoenix.HTML.safe_to_string(Phoenix.HTML.Tag.content_tag(:p, group_membership_request.user.name))
      end
      column :group, fn(group_membership_request) ->
        Phoenix.HTML.safe_to_string(Phoenix.HTML.Tag.content_tag(:p, group_membership_request.group.name))
      end
    end
  end
end
