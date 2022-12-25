defmodule TaskManagerTest do
  use ExUnit.Case
  doctest Kanban

  alias Kanban.TaskManager

  test "start_task" do
    pid = TaskManager.start_task("My task", 5, "My project")
    assert Process.alive?(pid)
  end
end
