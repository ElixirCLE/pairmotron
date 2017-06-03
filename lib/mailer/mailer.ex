defmodule Pairmotron.Mailer do
  @moduledoc """
  The Pairmotron.Mailer module simply provides an interface to Bamboo.Mailer
  for use within the Pairmotron app.
  """
  use Bamboo.Mailer, otp_app: :pairmotron
end
