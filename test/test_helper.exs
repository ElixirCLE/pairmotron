ExUnit.configure(exclude: [skip: true])
ExUnit.start

Ecto.Adapters.SQL.Sandbox.mode(Pairmotron.Repo, :manual)
