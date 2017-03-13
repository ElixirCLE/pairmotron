defmodule Pairmotron.ExAdmin.Group do
  @moduledoc false
  use ExAdmin.Register
  alias Pairmotron.{Repo, User}

  register_resource Pairmotron.Group do
    filter [:id, :name]
    index do
      selectable_column()

      column :id
      column :name, fn(group) ->
        Phoenix.HTML.safe_to_string(Phoenix.HTML.Tag.content_tag(:p, group.name))
      end
      column :owner, fn(group) ->
        Phoenix.HTML.safe_to_string(Phoenix.HTML.Tag.content_tag(:p, group.owner.name))
      end
    end

    show group do
      attributes_table do
        row :name, fn(group) ->
          Phoenix.HTML.safe_to_string(Phoenix.HTML.Tag.content_tag(:p, group.name))
        end
        row :owner, fn(group) ->
          Phoenix.HTML.safe_to_string(Phoenix.HTML.Tag.content_tag(:p, group.owner.name))
        end
        row :description, fn(group) ->
          Phoenix.HTML.safe_to_string(Phoenix.HTML.Tag.content_tag(:p, group.description))
        end
      end
    end

    form group do
      inputs do
        input group, :name
        input group, :owner, collection: Repo.all(User) |> Enum.map(&(Phoenix.HTML.safe_to_string(Phoenix.HTML.Tag.content_tag(:p, &1.name))))
        input group, :description
      end
    end
  end
end
