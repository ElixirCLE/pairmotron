defimpl Canada.Can, for: Pairmotron.User do
  alias Pairmotron.{Group, PairRetro, User}

  def can?(%User{is_admin: true}, _, _), do: true

  def can?(%User{id: user_id}, action, %PairRetro{user_id: user_id})
    when action in [:edit, :update, :show, :delete], do: true

  def can?(%User{id: user_id}, action, %User{id: user_id})
    when action in [:edit, :update, :delete], do: true

  def can?(%User{id: user_id}, action, %Group{owner_id: user_id})
    when action in [:edit, :update, :delete], do: true

  def can?(%User{}, _, _), do: false
end
