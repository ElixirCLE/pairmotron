defmodule Pairmotron.ViewHelpers do
  @moduledoc """
  Contains various functions that are used by a number of views/templates. Auto
  imported into views and templates through web.ex.
  """
  alias Pairmotron.Types

  @doc """
  Given a user, returns true if that user has a role and that role's
  is_admin property is true. Errors if the user's role is not loaded
  and the user has a role. This is to prevent calling the database in
  a view.
  """
  @spec is_admin?(Types.user) :: boolean()
  def is_admin?(user) do
    user.is_admin
  end

  @doc """
  Given a changeset and a field that whose value is needed, returns
  that value and only that value. Useful for hidden fields in forms.
  """
  @spec value_from_changeset(%Ecto.Changeset{}, atom()) :: term()
  def value_from_changeset(changeset, field) do
    changeset
    |> Ecto.Changeset.fetch_field(field)
    |> case do
      {_, value} -> value
      _ -> "error"
    end
  end
end
