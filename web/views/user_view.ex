defmodule Pairmotron.UserView do
  use Pairmotron.Web, :view

  def active_text(%Pairmotron.User{active: true}) do
    "Active"
  end
  def active_text(%Pairmotron.User{active: false}) do
    "Inactive"
  end
end
