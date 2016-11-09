defmodule Pairmotron.PageController do
  use Pairmotron.Web, :controller

  alias Pairmotron.User
  alias Pairmotron.Mixer
  alias Pairmotron.Pairer

  def index(conn, _params) do
    {_year, week} = Timex.iso_week(Timex.today)
    pairs = Repo.all(User.active_users)
      |> Mixer.mixify(week)
      |> Pairer.generate_pairs
    render conn, "index.html", pairs: pairs
  end
end
