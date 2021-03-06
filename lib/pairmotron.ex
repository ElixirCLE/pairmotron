defmodule Pairmotron do
  @moduledoc false
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @spec start(atom(), map()) :: Supervisor.on_start
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Pairmotron.Repo, []),
      # Start the endpoint when the application starts
      supervisor(Pairmotron.Endpoint, []),
      # Start your own worker by calling: Pairmotron.Worker.start_link(arg1, arg2, arg3)
      # worker(Pairmotron.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Pairmotron.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @spec config_change(map(), map(), map()) :: :ok
  def config_change(changed, _new, removed) do
    Pairmotron.Endpoint.config_change(changed, removed)
    :ok
  end
end
