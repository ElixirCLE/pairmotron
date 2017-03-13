defmodule Pairmotron.ExAdmin.User do
  @moduledoc false
  use ExAdmin.Register

  register_resource Pairmotron.User do
    filter except: [:password_hash]
    index do
      selectable_column()

      column :id
      column :name, fn(user) ->
        Phoenix.HTML.safe_to_string(Phoenix.HTML.Tag.content_tag(:p, user.name))
      end
      column :email, fn(user) ->
        Phoenix.HTML.safe_to_string(Phoenix.HTML.Tag.content_tag(:p, user.email))
      end
      column :active, toggle: true
      column :is_admin, toggle: true
    end

    show user do
      attributes_table do
        row :id
        row :name, fn(user) ->
          Phoenix.HTML.safe_to_string(Phoenix.HTML.Tag.content_tag(:p, user.name))
        end
        row :email, fn(user) ->
          Phoenix.HTML.safe_to_string(Phoenix.HTML.Tag.content_tag(:p, user.email))
        end
        row :active, toggle: true
        row :is_admin, toggle: true
        row :inserted_at
        row :updated_at
      end
    end

    form user do
      inputs do
        input user, :name
        input user, :email
        input user, :active
        input user, :is_admin
        input user, :password, type: :password
        input user, :password_confirmation, type: :password
      end
    end
  end
end
