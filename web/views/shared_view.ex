defmodule Pairmotron.SharedView do
  use Pairmotron.Web, :view
  import Pairmotron.PairView, only: [current_user_in_pair: 2, user_retro: 1]
end
