# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :pairmotron,
  ecto_repos: [Pairmotron.Repo]

# Configures the endpoint
config :pairmotron, Pairmotron.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "WjUF2F1EjOXnaJT68fs9SSRgYLUsJbuxK+jazDxCm6VL/VyBX0Z08ZYad3o0yUOb",
  render_errors: [view: Pairmotron.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Pairmotron.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :guardian, Guardian,
  allowed_algos: ["ES512"],
  verify_module: Guardian.JWT,
  issuer: "Pairmotron",
  ttl: { 30, :days },
  verify_issuer: true, # optional
  secret_key: %{
    "crv" => "P-521",
    "d" => "axDuTtGavPjnhlfnYAwkHa4qyfz2fdseppXEzmKpQyY0xd3bGpYLEF4ognDpRJm5IRaM31Id2NfEtDFw4iTbDSE",
    "kty" => "EC",
    "x" => "AL0H8OvP5NuboUoj8Pb3zpBcDyEJN907wMxrCy7H2062i3IRPF5NQ546jIJU3uQX5KN2QB_Cq6R_SUqyVZSNpIfC",
    "y" => "ALdxLuo6oKLoQ-xLSkShv_TA0di97I9V92sg1MKFava5hKGST1EKiVQnZMrN3HO8LtLT78SNTgwJSQHAXIUaA-lV"
  },
  serializer: Pairmotron.GuardianSerializer

config :canary,
  repo: Pairmotron.Repo,
  not_found_handler: {Pairmotron.ControllerHelpers, :handle_resource_not_found}

config :ex_admin,
  repo: Pairmotron.Repo,
  module: Pairmotron,
  modules: [
    Pairmotron.ExAdmin.Dashboard,
    Pairmotron.ExAdmin.Group,
    Pairmotron.ExAdmin.Project,
    Pairmotron.ExAdmin.User,
    Pairmotron.ExAdmin.UserGroup,
    Pairmotron.ExAdmin.GroupMembershipRequest
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

config :xain, :after_callback, {Phoenix.HTML, :raw}

