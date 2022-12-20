defmodule IssueTest do
  use ExUnit.Case
  doctest Kanban

  alias Kanban.Data.Issue

  @valid_attrs %{title: "Title", description: "Description", type: "feature"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Issue.changeset(%Issue{}, @valid_attrs)
    assert changeset.valid?
  end

  describe "changeset with invalid attributes" do
    test "when title is blank" do
      changeset = Issue.changeset(%Issue{}, Map.delete(@valid_attrs, :title))
      refute changeset.valid?
    end

    test "when due is blank" do
      changeset = Issue.changeset(%Issue{}, Map.delete(@valid_attrs, :description))
      refute changeset.valid?
    end
  end
end
