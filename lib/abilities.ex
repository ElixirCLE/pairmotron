defimpl Canada.Can, for: Pairmotron.User do
  alias Pairmotron.{Group, PairRetro, Project, User}

  def can?(%User{is_admin: true}, _, _), do: true

  def can?(%User{id: user_id}, action, %PairRetro{user_id: user_id})
    when action in [:edit, :update, :show, :delete], do: true

  def can?(%User{id: user_id}, action, %Group{owner_id: user_id})
    when action in [:edit, :update, :delete], do: true

  def can?(%User{id: user_id}, :show, project = %Project{group_id: nil}) do
    project = project |> Pairmotron.Repo.preload([{:pair_retros, :user}])
    project.pair_retros
    |> Enum.any?(fn retro -> retro.user.id == user_id end)
  end

  def can?(%User{id: user_id}, :show, project = %Project{}) do
    project = project |> Pairmotron.Repo.preload([{:group, :users}])
    project.group.users
    |> Enum.any?(fn user -> user.id == user_id end)
  end

  def can?(%User{}, action, %Project{group_id: nil})
    when action in [:edit, :update, :delete], do: false

  def can?(%User{id: user_id}, action, project = %Project{})
    when action in [:edit, :update, :delete] do
    project = project |> Pairmotron.Repo.preload([{:group, :users}])
    cond do
      project.group.owner_id == user_id -> true
      !Enum.any?(project.group.users, &(&1.id == user_id)) -> false
      project.created_by_id == user_id -> true
      true -> false
    end
  end

  def can?(%User{}, _, _), do: false
end
