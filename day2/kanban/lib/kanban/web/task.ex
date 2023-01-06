defmodule Kanban.Web.Task do
  use Plug.Router

  plug :match
  plug :dispatch

  alias Kanban.Data.{Project, Task}
  alias Kanban.TaskManager

  get "/get_task_state" do
    conn = Plug.Conn.fetch_query_params(conn)
    task_id = conn.params["title"]

    case Registry.lookup(Kanban.TaskRegistry, task_id) do
      [] -> response(conn, 404, "Not found")
      _  -> response(conn, 200, Kanban.query_task(task_id))
    end
  end

  post "/add_task" do
    conn = Plug.Conn.fetch_query_params(conn)

    case Task.create(conn.params) do
      task = %Task{} ->
        Kanban.TaskFSM.start_link(task: task)

        response(conn, 200, "Task has been created.")
      {:error, errors} ->
        response(conn, 422, inspect(errors))
    end
  end

  post "/start_task" do
    conn = Plug.Conn.fetch_query_params(conn)
    task_id = conn.params["title"]

    case Registry.lookup(Kanban.TaskRegistry, task_id) do
      [] -> response(conn, 404, "Not found")
      _ -> Kanban.start_task(task_id)
           response(conn, 200, "OK")
    end
  end

  def child_spec(_arg) do
    Plug.Adapters.Cowboy.child_spec(
      scheme: :http,
      options: [port: 5454],
      plug: __MODULE__
    )
  end

  defp response(conn, status, resp_body) do
    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(status, resp_body)
  end
end
