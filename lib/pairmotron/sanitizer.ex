defmodule Pairmotron.Sanitizer do
  @moduledoc """
  Wraps HtmlSanitizeEx and provides a changeset validator that strips tags from use input
  """
  alias HtmlSanitizeEx
  alias Ecto.Changeset

  @doc """
  Remove tags from the provided string
  """
  @spec strip_tags(binary()) :: binary()
  def strip_tags(text) do
    HtmlSanitizeEx.strip_tags(text)
  end

  @doc """
  Remove tags from the fields in the changeset
  """
  @spec sanitize(map() | %Ecto.Changeset{}, atom() | list(atom())) :: %Ecto.Changeset{}
  def sanitize(changeset, field) when is_atom(field) do
    case changeset do
      %Ecto.Changeset{changes: %{^field => value}} ->
        Changeset.put_change(changeset, field, strip_tags(value))
      _ ->
        changeset
    end
  end
  def sanitize(changeset, [field|fields]) do
    changeset
    |> sanitize(field)
    |> sanitize(fields)
  end
  def sanitize(changeset, _), do: changeset
end
