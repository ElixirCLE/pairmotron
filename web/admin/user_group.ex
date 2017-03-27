defmodule Pairmotron.ExAdmin.UserGroup do
  @moduledoc false
  use ExAdmin.Register

  register_resource Pairmotron.UserGroup do
    filter [:user, :group, :is_admin]
    action_items only: [:new, :edit, :delete, :show]
  end
end
