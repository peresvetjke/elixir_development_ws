defmodule Kanban.Web.TaskTest do
  use ExUnit.Case
  use Plug.Test

  @opts Kanban.Web.Task.init([])

  describe "/get_task" do
    test "returns 200 when found" do
      :post |> conn("/add_task?title=title&due=2022-01-23 23:50:07") |> Kanban.Web.Task.call(@opts)
      conn = :get |> conn("/get_task_state?title=title") |> Kanban.Web.Task.call(@opts)

      assert conn.status == 200
      assert conn.resp_body == "idle"
    end

    test "returns 404 when not found" do
      conn = :get |> conn("/get_task_state?title=task") |> Kanban.Web.Task.call(@opts)

      assert conn.status == 404
      assert conn.resp_body == "Not found"
    end
  end

  describe "/add_task" do
    test "returns OK when params are valid" do
      conn = :post |> conn("/add_task?title=title&due=2022-01-23 23:50:07") |> Kanban.Web.Task.call(@opts)

      assert conn.status == 200
      assert conn.resp_body == "Task has been created."
    end

    test "creates task when params are valid" do
      assert Registry.lookup(Kanban.TaskRegistry, "title") == []

      conn = :post |> conn("/add_task?title=title&due=2022-01-23 23:50:07") |> Kanban.Web.Task.call(@opts)

      refute Registry.lookup(Kanban.TaskRegistry, "title") == []
      assert Kanban.query_task("title") == "idle"
    end

    test "returns Unprocessable entity with errors when params are invalid" do
      conn = :post |> conn("/add_task?title=title&due=wrong") |> Kanban.Web.Task.call(@opts)

      assert conn.status == 422
      assert conn.resp_body == "[due: {\"is invalid\", [type: :utc_datetime, validation: :cast]}]"
    end
  end

  describe "/start_task" do
    test "returns OK" do
      conn = :post |> conn("/add_task?title=title&due=2022-01-23 23:50:07") |> Kanban.Web.Task.call(@opts)
      assert conn.status == 200

      conn = :post |> conn("/start_task?title=title") |> Kanban.Web.Task.call(@opts)
      assert conn.status == 200
      assert conn.resp_body == "OK"
    end

    test "updates status" do
      conn = :post |> conn("/add_task?title=title&due=2022-01-23 23:50:07") |> Kanban.Web.Task.call(@opts)
      assert Kanban.query_task("title") == "idle"

      conn = :post |> conn("/start_task?title=title") |> Kanban.Web.Task.call(@opts)
      assert Kanban.query_task("title") == "doing"
    end
  end
end
