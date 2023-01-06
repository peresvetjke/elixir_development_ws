defmodule ProjectTest do
  use ExUnit.Case
  doctest Kanban

  alias Kanban.Data.Project

  @valid_attrs %{title: "Title", description: "Description"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Project.changeset(%Project{}, @valid_attrs)
    assert changeset.valid?
  end

  describe "changeset with invalid attributes" do
    test "when title is blank" do
      changeset = Project.changeset(%Project{}, Map.delete(@valid_attrs, :title))
      refute changeset.valid?
    end
  end
end
