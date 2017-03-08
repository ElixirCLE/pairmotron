defmodule Pairmotron.Gravatar do
  @moduledoc """
  Handles the integration with Gravatar. Used by templates to retrieve the
  proper gravatar image URL for a given user.
  """

  @doc """
  Given an email, returns the URL for the Gravatar avatar associated with that
  email.
  """
  @spec url(email :: String.t) :: String.t
  def url(email) do
    md5_email = :crypto.hash(:md5, email)
    "https://gravatar.com/avatar/" <> (md5_email |> Base.encode16(case: :lower))
  end
end
