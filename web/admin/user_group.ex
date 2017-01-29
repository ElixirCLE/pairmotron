defmodule Pairmotron.ExAdmin.UserGroup do
  use ExAdmin.Register

  register_resource Pairmotron.UserGroup do
    filter [:user, :group]
    action_items only: [:new, :delete]
  end
end
