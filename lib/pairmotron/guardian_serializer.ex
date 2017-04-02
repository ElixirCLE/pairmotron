defmodule Pairmotron.GuardianSerializer do
  @moduledoc """
  Handles the conversion to and from a Guardian JWT.
  """
  @behaviour Guardian.Serializer

  alias Pairmotron.{Repo, User}

  @spec for_token(any()) :: {:ok, String.t} | {:error, String.t}
  def for_token(user = %User{}), do: {:ok, "User:#{user.id}"}
  def for_token(_), do: {:error, "Unknown resource type"}

  @spec from_token(String.t) :: {:ok, String.t} | {:error, String.t}
  def from_token("User:" <> id), do: {:ok, Repo.get(User, id)}
  def from_token(_), do: {:error, "Unknown resource type"}
end
