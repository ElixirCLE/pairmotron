defmodule Pairmotron.ViewHelpers do
  @doc """
  Given a user, returns true if that user has a role and that role's
  is_admin property is true. Errors if the user's role is not loaded
  and the user has a role. This is to prevent calling the database in
  a view.
  """
  def is_admin?(user) do
    user.is_admin
  end

  @doc """
  Given a changeset and a field that whose value is needed, returns
  that value and only that value. Useful for hidden fields in forms.
  """
  def value_from_changeset(changeset, field) do
    elem(Ecto.Changeset.fetch_field(changeset, field), 1)
  end
end
