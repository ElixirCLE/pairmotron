defimpl Canada.Can, for: Pairmotron.User do
  alias Pairmotron.{PairRetro, Role, User}

  def can?(%User{id: user_id}, action, %PairRetro{user_id: user_id})
    when action in [:edit, :update, :show, :delete], do: true

  def can?(%User{id: user_id}, action, %User{id: user_id})
    when action in [:edit, :update, :delete], do: true

  def can?(%User{role_id: role_id}, _, _) when not is_nil(role_id) do
    case Pairmotron.Repo.get(Role, role_id) do
      nil -> false
      role -> role.is_admin
    end
  end

  def can?(%User{}, _, _), do: false
end
