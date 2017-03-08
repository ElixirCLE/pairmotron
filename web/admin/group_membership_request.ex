defmodule Pairmotron.ExAdmin.GroupMembershipRequest do
  @moduledoc false
  use ExAdmin.Register

  register_resource Pairmotron.GroupMembershipRequest do
    filter [:user, :group, :initiated_by_user]
  end
end
