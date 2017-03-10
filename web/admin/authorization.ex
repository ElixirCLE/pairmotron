alias Pairmotron.Authentication, as: Auth
alias Pairmotron.Authorization, as: Authz

defimpl ExAdmin.Authorization, for: Pairmotron.User do
  @spec authorize_query(any(), %Plug.Conn{}, %Ecto.Query{}, any(), any()) :: %Ecto.Query{}
  def authorize_query(resource, conn, query, _action, _id),
    do: Authz.authorize_user_query(resource, Auth.current_user(conn), query)

  @spec authorize_action(any(), %Plug.Conn{}, atom()) :: boolean()
  def authorize_action(_resource, conn, action),
    do: Authz.authorize_actions(action, Auth.current_user(conn),
          except: [:create, :new, :destroy, :delete])
end
