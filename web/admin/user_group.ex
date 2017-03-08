defmodule Pairmotron.ExAdmin.UserGroup do
  @moduledoc false
  use ExAdmin.Register

  register_resource Pairmotron.UserGroup do
    filter [:user, :group]
    action_items only: [:new, :delete, :show]
  end
end
