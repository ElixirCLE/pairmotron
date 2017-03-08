defmodule Pairmotron.ExAdmin.Dashboard do
  @moduledoc false
  use ExAdmin.Register

  alias Pairmotron.{Repo, User}

  register_page "Dashboard" do
    menu priority: 1, label: "Dashboard"
    content do
      columns do
        column do
          panel "Statistics" do
            markup_contents do
              user_count = User |> Repo.aggregate(:count, :id)
              p "#{user_count} Users"
            end
          end
        end
      end
    end
  end
end
