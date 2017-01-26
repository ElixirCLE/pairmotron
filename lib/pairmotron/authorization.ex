defmodule Pairmotron.Authorization do
  import Ecto.Query

  def authorize_user_query(_, %{is_admin: true}, query), do: query
  def authorize_user_query(_resource, user, query) do
    where(query, [u], u.id == ^user.id)
  end

  def authorize_actions(_, %{is_admin: true}, _), do: true
  def authorize_actions(action, _, actions) when is_atom(action) do
    only = actions[:only]
    except = actions[:except]
    cond do
      is_list(only) -> action in only
      is_list(except) -> not action in except
      true -> false
    end
  end
end
