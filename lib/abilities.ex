defimpl Canada.Can, for: Pairmotron.User do
  alias Pairmotron.{Group, PairRetro, Project, User}

  def can?(%User{is_admin: true}, _, _), do: true

  def can?(%User{id: user_id}, action, %PairRetro{user_id: user_id})
    when action in [:edit, :update, :show, :delete], do: true

  def can?(%User{id: user_id}, action, %Group{owner_id: user_id})
    when action in [:edit, :update, :delete], do: true

  def can?(%User{id: user_id}, :show, project = %Project{}) do
    if is_nil(project.group_id) do
      false
    else
      project = project |> Pairmotron.Repo.preload([{:group, :users}])
      project.group.users
      |> Enum.any?(fn user -> user.id == user_id end)
    end
  end

  def can?(%User{id: user_id}, action, project = %Project{})
    when action in [:edit, :update, :delete] do
    if is_nil(project.group_id) do
      false
    else
      project = project |> Pairmotron.Repo.preload(:group)
      project.group.owner_id == user_id
    end
  end

  def can?(%User{}, _, _), do: false
end
