defmodule Kanban.TaskManager do
  @moduledoc """
  The supervisor for all the task processes/fsms.
  """
  use DynamicSupervisor

  alias Kanban.Data.Task

  @type _ :: _

  @spec start_link(list()) :: tuple()
  def start_link(init_arg \\ []),
    do: DynamicSupervisor.start_link(__MODULE__, init_arg, name: Kanban.TaskManager)

  @impl true
  @spec init(any) ::
          {:ok,
           %{
             extra_arguments: list,
             intensity: non_neg_integer,
             max_children: :infinity | non_neg_integer,
             period: pos_integer,
             strategy: :one_for_one
           }}
  def init(_init_arg),
    do: DynamicSupervisor.init(strategy: :one_for_one)

  @spec start_task(Task.t()) :: pid() | nil
  def start_task(%Task{} = task) do
    Kanban.TaskManager
    |> DynamicSupervisor.start_child({Kanban.TaskFSM, task: task})
    |> case do
      {:ok, pid} ->
        Kanban.State.put(task.title, task.state)
        pid

      {:error, {:already_started, pid}} ->
        pid

      _ ->
        nil
    end
  end

  @spec start_task(String.t(), integer(), String.t()) :: pid() | nil
  def start_task(title, due_days, project_title) do
    title
    |> Task.create(due_days, project_title)
    |> start_task()
  end
end
