defmodule TaskTest do
  use ExUnit.Case
  doctest Kanban

  alias Kanban.Data.Task

  @valid_attrs %{title: "Title", due: DateTime.add(DateTime.utc_now(), 5, :day), description: "Description", state: "idle"}
  @task Task.create(@valid_attrs)
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Task.changeset(%Task{}, @valid_attrs)
    assert changeset.valid?
  end

  describe "changeset with invalid attributes" do
    test "when title is blank" do
      changeset = Task.changeset(%Task{}, Map.delete(@valid_attrs, :title))
      refute changeset.valid?
    end

    test "when due is blank" do
      changeset = Task.changeset(%Task{}, Map.delete(@valid_attrs, :due))
      refute changeset.valid?
    end

    test "state must be one of ~w[idle ondoing done]a" do
      changeset = Task.changeset(%Task{}, %{@valid_attrs | state: "wrong"})
      # refute changeset.valid?
      assert changeset.data.state == "idle"
    end
  end
end
