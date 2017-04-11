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

  @doc """
  Convenience function for outputting boolean values with an upper case first
  letter rather than all lowercase.
  """
  @spec format_boolean(boolean()) :: String.t
  def format_boolean(true), do: "True"
  def format_boolean(false), do: "False"

  @doc """
  Takes a list of Ecto structs, and outputs a list suitable for a select
  element on a Phoenix.HTML.form. The Ecto schema for the struct passed in must
  have a name property and an id property.
  """
  @spec data_as_select(List.t) :: [{binary(), integer()}]
  def data_as_select(data) do
    data
    |> Enum.map(&["#{&1.name}": &1.id])
    |> List.flatten
  end

  @doc """
  Takes a list of Ecto structs, and outputs a list suitable for a select
  element on a Phoenix.HTML.form. The Ecto schema for the struct passed in must
  have a name property and an id property.

  The only difference between this and data_as_select is that this also
  displays the id in the dropdown for use in admin routes.
  """
  @spec data_as_select_with_ids(List.t) :: [{binary(), integer()}]
  def data_as_select_with_ids(data) do
    data
    |> Enum.map(&["#{&1.id}: #{&1.name}": &1.id])
    |> List.flatten
  end
end
