defmodule Pairmotron.Gravatar do
  def url(email) do
    "https://gravatar.com/avatar/" <> (:crypto.hash(:md5, email) |> Base.encode16(case: :lower))
  end
end
