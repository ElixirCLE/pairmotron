#alias Pairmotron.Plug.Authenticate, as: Auth
#alias Pairmotron.Authorization, as: Authz
#
#defimpl ExAdmin.Authorization, for: Pairmotron.User do
#  def authorize_query(resource, conn, query, _action, _id),
#    do: Authz.authorize_user_query(resource, conn, query)
#  def authorize_action(_resource, conn, action),
#    do: Authz.authorize_actions(action, Auth.current_user(conn),
#          except: [:create, :new, :destroy, :delete])
#end

defmodule Pairmotron.Authorization do
  import Ecto.Query

  def authorize_user_query(%{admin: true}, _conn, query), do: query
  def authorize_user_query(user, _conn, query) do
    IO.inspect user
    IO.inspect query
    id = user.id
    where(query, [u], u.id == ^id)
  end

  def authorize_actions(_, %{admin: true}, _), do: true
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
