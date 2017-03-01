defmodule Pairmotron.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: Pairmotron.Repo

  alias Pairmotron.{Group, Project, User}

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
      is_admin: true
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

  def project_factory do
    %Project{
      name: sequence(:name, &"project #{&1}"),
      description: sequence(:description, &"description #{&1}"),
      url: sequence(:url, &"http://example-#{&1}.com")
    }
  end

  def group_factory do
    %Group{
      name: sequence(:name, &"group #{&1}"),
      owner: build(:user),
      users: []
    }
  end

  def group_membership_request_factory do
    %Pairmotron.GroupMembershipRequest{}
  end

  def pair_factory do
    {current_year, current_week} = Timex.iso_week(Timex.today)
    %Pairmotron.Pair{
      year: current_year,
      week: current_week,
      group: build(:group)
    }
  end

  def retro_factory do
    %Pairmotron.PairRetro{
      pair_date: Timex.today |> Timex.to_erl |> Ecto.Date.from_erl,
      user: build(:user),
      pair: build(:pair)
    }
  end
end
