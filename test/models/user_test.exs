defmodule Pairmotron.UserTest do
  use Pairmotron.ModelCase

  alias Pairmotron.User

  @valid_attrs %{email: "some content", name: "some content"}
  @invalid_attrs %{}

  describe "changeset/2" do
    test "with valid attributes is valid" do
      changeset = User.changeset(%User{}, @valid_attrs)
      assert changeset.valid?
    end

    test "with valid attributes with password change updates the password_hash" do
      attrs = Map.merge(@valid_attrs, %{password: "password", password_confirmation: "password"})
      changeset = User.changeset(%User{}, attrs)
      assert Map.has_key?(changeset.changes, :password_hash)
      assert changeset.valid?
    end

    test "with valid attributes with no password change does not update password_hash" do
      changeset = User.changeset(%User{}, @valid_attrs)
      refute Map.has_key?(changeset.changes, :password_hash)
      assert changeset.valid?
    end

    test "with invalid attributes with password change does not update password_hash" do
      attrs = Map.merge(@invalid_attrs, %{password: "password", password_confirmation: "password"})
      changeset = User.changeset(%User{}, attrs)
      refute Map.has_key?(changeset.changes, :password_hash)
      refute changeset.valid?
    end

    test "is invalid and does not update password_hash if password and password_confirmation do not match" do
      attrs = Map.merge(@valid_attrs, %{password: "password", password_confirmation: "not_password"})
      changeset = User.changeset(%User{}, attrs)
      refute Map.has_key?(changeset.changes, :password_hash)
      refute changeset.valid?
    end

    test "is invalid without name" do
      attrs = Map.delete(@valid_attrs, :name)
      changeset = User.changeset(%User{}, attrs)
      refute changeset.valid?
    end

    test "is invalid without email" do
      attrs = Map.delete(@valid_attrs, :email)
      changeset = User.changeset(%User{}, attrs)
      refute changeset.valid?
    end

    test "can alter the is_admin field" do
      attrs = Map.merge(@valid_attrs, %{is_admin: true})
      changeset = User.changeset(%User{}, attrs)
      assert Map.has_key?(changeset.changes, :is_admin)
      assert changeset.valid?
    end

    test "can alter the active field" do
      attrs = Map.merge(@valid_attrs, %{active: true})
      changeset = User.changeset(%User{}, attrs)
      assert Map.has_key?(changeset.changes, :active)
      assert changeset.valid?
    end

    test "with invalid attributes is invalid" do
      changeset = User.changeset(%User{}, @invalid_attrs)
      refute changeset.valid?
    end
  end

  @valid_reg_attrs %{email: "some content", name: "some content", password: "password", password_confirmation: "password"}

  describe "registration_changeset/2" do
    test "with valid attributes is valid" do
      changeset = User.registration_changeset(%User{}, @valid_reg_attrs)
      assert changeset.valid?
    end

    test "with valid attributes with password change updates the password_hash" do
      attrs = Map.merge(@valid_reg_attrs, %{password: "password"})
      changeset = User.registration_changeset(%User{}, attrs)
      assert Map.has_key?(changeset.changes, :password_hash)
      assert changeset.valid?
    end

    test "with valid attributes with no password change does not update password_hash and is invalid" do
      changeset = User.registration_changeset(%User{}, @valid_attrs)
      refute Map.has_key?(changeset.changes, :password_hash)
      refute changeset.valid?
    end

    test "with invalid attributes with password change does not update password_hash" do
      attrs = Map.merge(@invalid_attrs, %{password: "password"})
      changeset = User.registration_changeset(%User{}, attrs)
      refute Map.has_key?(changeset.changes, :password_hash)
      refute changeset.valid?
    end

    test "is invalid and does not update password_hash if password and password_confirmation do not match" do
      attrs = Map.merge(@valid_reg_attrs, %{password: "password", password_confirmation: "not_password"})
      changeset = User.registration_changeset(%User{}, attrs)
      refute Map.has_key?(changeset.changes, :password_hash)
      refute changeset.valid?
    end

    test "is invalid without name" do
      attrs = Map.delete(@valid_reg_attrs, :name)
      changeset = User.registration_changeset(%User{}, attrs)
      refute changeset.valid?
    end

    test "is invalid without email" do
      attrs = Map.delete(@valid_reg_attrs, :email)
      changeset = User.registration_changeset(%User{}, attrs)
      refute changeset.valid?
    end

    test "cannot alter the is_admin field" do
      attrs = Map.merge(@valid_reg_attrs, %{is_admin: true})
      changeset = User.registration_changeset(%User{}, attrs)
      refute Map.has_key?(changeset.changes, :is_admin)
      assert changeset.valid?
    end

    test "can alter the active field" do
      attrs = Map.merge(@valid_reg_attrs, %{active: true})
      changeset = User.registration_changeset(%User{}, attrs)
      assert Map.has_key?(changeset.changes, :active)
      assert changeset.valid?
    end

    test "with invalid attributes is invalid" do
      changeset = User.registration_changeset(%User{}, @invalid_attrs)
      refute changeset.valid?
    end
  end

  describe "profile_changeset/2" do
    test "with valid attributes is valid" do
      changeset = User.profile_changeset(%User{}, @valid_attrs)
      assert changeset.valid?
    end

    test "with valid attributes with password change updates the password_hash" do
      attrs = Map.merge(@valid_attrs, %{password: "password"})
      changeset = User.profile_changeset(%User{}, attrs)
      assert Map.has_key?(changeset.changes, :password_hash)
      assert changeset.valid?
    end

    test "with valid attributes with no password change does not update password_hash" do
      changeset = User.profile_changeset(%User{}, @valid_attrs)
      refute Map.has_key?(changeset.changes, :password_hash)
      assert changeset.valid?
    end

    test "with invalid attributes with password change does not update password_hash" do
      attrs = Map.merge(@invalid_attrs, %{password: "password"})
      changeset = User.profile_changeset(%User{}, attrs)
      refute Map.has_key?(changeset.changes, :password_hash)
      refute changeset.valid?
    end

    test "is invalid and does not update password_hash if password and password_confirmation do not match" do
      attrs = Map.merge(@valid_attrs, %{password: "password", password_confirmation: "not_password"})
      changeset = User.profile_changeset(%User{}, attrs)
      refute Map.has_key?(changeset.changes, :password_hash)
      refute changeset.valid?
    end

    test "is invalid without name" do
      attrs = Map.delete(@valid_attrs, :name)
      changeset = User.profile_changeset(%User{}, attrs)
      refute changeset.valid?
    end

    test "is invalid without email" do
      attrs = Map.delete(@valid_attrs, :email)
      changeset = User.profile_changeset(%User{}, attrs)
      refute changeset.valid?
    end

    test "cannot alter the is_admin field" do
      attrs = Map.merge(@valid_attrs, %{is_admin: true})
      changeset = User.profile_changeset(%User{}, attrs)
      refute Map.has_key?(changeset.changes, :is_admin)
      assert changeset.valid?
    end

    test "can alter the active field" do
      attrs = Map.merge(@valid_attrs, %{active: true})
      changeset = User.profile_changeset(%User{}, attrs)
      assert Map.has_key?(changeset.changes, :active)
      assert changeset.valid?
    end

    test "with invalid attributes is invalid" do
      changeset = User.profile_changeset(%User{}, @invalid_attrs)
      refute changeset.valid?
    end
  end
end
