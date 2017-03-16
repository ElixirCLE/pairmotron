defmodule Pairmotron.SanitizerTest do
  use ExUnit.Case, async: true

  alias Ecto.Changeset
  alias Pairmotron.Sanitizer

  defmodule Example do
    use Ecto.Schema

    schema "examples" do
      field :title, :string
      field :description, :string
      field :some_text, :string
    end

    def changeset(schema, params) do
      Changeset.cast(schema, params, ~w(title description some_text))
    end
  end

  describe "strip_tags/1" do
    test "with empty string returns empty string" do
      assert "" == Sanitizer.strip_tags("")
    end

    test "with simple string returns simple string" do
      assert "simple" == Sanitizer.strip_tags("simple")
    end

    test "with tags removes out tags" do
      assert "content" == Sanitizer.strip_tags("<p>content</p>")
    end

    test "with only beginning tag removes tag" do
      assert "content" == Sanitizer.strip_tags("<p>content")
    end

    test "with only ending tag removes tag" do
      assert "content" == Sanitizer.strip_tags("content</p>")
    end

    test "with all caps tags removes tags" do
      assert "content" == Sanitizer.strip_tags("<SPAN>content</SPAN>")
    end

    test "with partial and complete tags removes tags" do
      assert "content" == Sanitizer.strip_tags("<div><p>content</p>")
      assert "content" == Sanitizer.strip_tags("<p>content</p></div>")
    end

    test "with incomplete tag does not remove tag" do
      assert "don" == Sanitizer.strip_tags("<p>don<t do this</p>")
    end
  end

  describe "sanitize/2" do
    test "changeset without sanitized field returns changeset" do
      change = Example.changeset(%Example{}, %{title: "bar"})
      assert change == Sanitizer.sanitize(change, :description)
    end

    test "changeset without tags returns changeset" do
      change = Example.changeset(%Example{}, %{title: "bar"})
      assert change == Sanitizer.sanitize(change, :title)
    end

    test "changeset with tags removes tags" do
      with_tags = Example.changeset(%Example{}, %{title: "<p>bar</p>"})
      changes = Sanitizer.sanitize(with_tags, :title) |> Changeset.get_change(:title)
      assert "bar" == changes
    end

    test "changeset with tags does not remove tags implicitly from other fields" do
      with_tags = Example.changeset(%Example{}, %{title: "<p>bar</p>", description: "foo"})
      changes = Sanitizer.sanitize(with_tags, :description) |> Changeset.get_change(:title)
      assert "<p>bar</p>" == changes
    end
  end

  describe "sanitize/3" do
    test "changeset without sanitized fields returns changeset" do
      change = Example.changeset(%Example{}, %{title: "bar"})
      assert change == Sanitizer.sanitize(change, [:description, :some_text])
    end

    test "changeset without tags returns changeset" do
      change = Example.changeset(%Example{}, %{title: "bar"})
      assert change == Sanitizer.sanitize(change, [:title, :some_text])
    end

    test "changeset with tags removes tags" do
      with_tags = Example.changeset(%Example{}, %{title: "<p>bar</p>", some_text: "<script>bark</script>"})
      changes = Sanitizer.sanitize(with_tags, [:title, :some_text])
      assert "bar" == changes |> Changeset.get_change(:title)
      assert "bark" == changes |> Changeset.get_change(:some_text)
    end

    test "changeset with tags does not remove tags implicitly from other fields" do
      with_tags = Example.changeset(%Example{}, %{title: "<p>bar</p>", description: "foo"})
      changes = Sanitizer.sanitize(with_tags, [:description, :some_text]) |> Changeset.get_change(:title)
      assert "<p>bar</p>" == changes
    end
  end
end
