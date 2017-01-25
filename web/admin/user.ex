defmodule Pairmotron.ExAdmin.User do
  use ExAdmin.Register

  register_resource Pairmotron.User do
    filter except: [:password_hash]
    index do
      selectable_column()

      column :id
      column :name
      column :email
      column :active, toggle: true
      column :is_admin, toggle: true
    end

    show user do
      attributes_table do
        row :id
        row :name
        row :email
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
