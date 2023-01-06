defmodule IssueFSMTest do
  use ExUnit.Case
  doctest Kanban

  alias Kanban.Data.Issue
  alias Kanban.IssueFSM

  @valid_attrs %{
    title: "Everything is so wrong.",
    description: "I think the best idea will be..",
    type: "feature"
  }
  @invalid_attrs %{}

  describe "start" do
    test "it updates state" do
      {:ok, pid} = IssueFSM.start_link(issue: Issue.create(@valid_attrs))
      assert IssueFSM.state(pid) == "idle"

      IssueFSM.start(pid)
      assert IssueFSM.state(pid) == "doing"
    end

    test "does not change state when state 'doing'" do
      {:ok, pid} = IssueFSM.start_link(issue: Issue.create(@valid_attrs))
      assert IssueFSM.start(pid)
      assert IssueFSM.state(pid) == "doing"

      assert IssueFSM.start(pid)
      assert IssueFSM.state(pid) == "doing"
    end

    test "does not change state when state 'done'" do
      {:ok, pid} = IssueFSM.start_link(issue: Issue.create(@valid_attrs))
      assert IssueFSM.start(pid)
      assert IssueFSM.finish(pid)
      assert IssueFSM.state(pid) == "done"

      assert IssueFSM.start(pid)
      assert IssueFSM.state(pid) == "done"
    end
  end

  describe "finish" do
    test "it updates state" do
      {:ok, pid} = IssueFSM.start_link(issue: Issue.create(@valid_attrs))
      IssueFSM.start(pid)
      assert IssueFSM.state(pid) == "doing"

      IssueFSM.finish(pid)
      assert IssueFSM.state(pid) == "done"
    end

    test "does not change state when state 'idle'" do
      {:ok, pid} = IssueFSM.start_link(issue: Issue.create(@valid_attrs))
      assert IssueFSM.state(pid) == "idle"
      assert IssueFSM.finish(pid)
      assert IssueFSM.state(pid) == "idle"
    end
  end

  describe "state" do
    {:ok, pid} = IssueFSM.start_link(issue: Issue.create(@valid_attrs))
    assert IssueFSM.state(pid) == "idle"
    IssueFSM.start(pid)
    assert IssueFSM.state(pid) == "doing"
    IssueFSM.finish(pid)
    assert IssueFSM.state(pid) == "done"
  end
end
