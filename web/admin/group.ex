defmodule Pairmotron.ExAdmin.Group do
  @moduledoc false
  use ExAdmin.Register

  register_resource Pairmotron.Group do
    filter [:id, :name, :owner]
  end
end
