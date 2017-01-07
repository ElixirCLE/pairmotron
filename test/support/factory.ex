defmodule Pairmotron.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: Pairmotron.Repo

  alias Pairmotron.{Project, Role, User}

  def user_factory do
    %User{
      name: sequence(:first_name, &"name #{&1}"),
      email: sequence(:email, &"email-#{&1}@example.com"),
      active: true,
      password_hash: "12345678"
    }
  end

  def user_admin_factory do
    %User{
      name: sequence(:first_name, &"name #{&1}"),
      email: sequence(:email, &"email-#{&1}@example.com"),
      active: true,
      password_hash: "12345678",
      role: build(:role, is_admin: true)
    }
  end

  def user_with_password_factory do
    %User{
      name: sequence(:first_name, &"name #{&1}"),
      email: sequence(:email, &"email-#{&1}@example.com"),
      active: true,
      password: "12345678",
      password_confirmation: "12345678",
      password_hash: Comeonin.Bcrypt.hashpwsalt("12345678")
    }
  end

  def role_factory do
    %Role{
      name: sequence(:role_name, &"role #{&1}"),
      is_admin: false
    }
  end

  def project_factory do
    %Project{
      name: sequence(:name, &"project #{&1}"),
      description: sequence(:description, &"description #{&1}"),
      url: sequence(:url, &"http://example-#{&1}.com")
    }
  end

end
