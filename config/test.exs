use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :pairmotron, Pairmotron.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :pairmotron, Pairmotron.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DB_ENV_POSTGRES_USER"),
  password: System.get_env("DB_ENV_POSTGRES_PASSWORD"),
  database: "pairmotron_test",
  hostname: System.get_env("DB_ENV_POSTGRES_HOST"),
  pool: Ecto.Adapters.SQL.Sandbox

config :pairmotron, Pairmotron.Mailer,
  adapter: Bamboo.TestAdapter
