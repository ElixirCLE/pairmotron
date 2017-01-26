alias Pairmotron.Authentication, as: Auth
alias Pairmotron.Authorization, as: Authz


defimpl ExAdmin.Authorization, for: Pairmotron.User do
  def authorize_query(resource, conn, query, _action, _id),
    do: Authz.authorize_user_query(resource, Auth.current_user(conn), query)
  def authorize_action(_resource, conn, action),
    do: Authz.authorize_actions(action, Auth.current_user(conn),
          except: [:create, :new, :destroy, :delete])
end
