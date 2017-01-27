defmodule Pairmotron.Repo do
  use Ecto.Repo, otp_app: :pairmotron
  use Scrivener, page_size: 10
end
