defmodule Pairmotron.PageController do
  use Pairmotron.Web, :controller

  alias Pairmotron.User
  alias Pairmotron.Mixer
  alias Pairmotron.Pairer

  def index(conn, _params) do
    {_year, week} = Timex.iso_week(Timex.today)
    users = Repo.all(User)
      |> Mixer.mixify(week)
      |> Pairer.generate_pairs
    render conn, "index.html", users: users
  end
end
