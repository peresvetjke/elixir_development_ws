defmodule Kanban.IssueFSM do
  @moduledoc """
  Process to be run
  """

  alias Kanban.Data.Issue

  use GenServer, restart: :transient

  require Logger

  def start_link(issue: %Issue{state: "idle", title: title} = issue)
      when not is_nil(title) do
    GenServer.start_link(__MODULE__, issue, name: {:via, Registry, {Kanban.IssueRegistry, title}})
  end

  def start(pid) do
    GenServer.cast(pid, {:transition, :start})
  end

  def finish(pid) do
    GenServer.cast(pid, {:transition, :finish})
  end

  def state(pid) do
    GenServer.call(pid, :state)
  end

  @impl GenServer
  def terminate(:normal, issue) do
    Kanban.State.del(issue.title)
  end

  @impl GenServer
  def init(state), do: {:ok, state}

  @impl GenServer
  def handle_cast({:transition, :start}, %Issue{state: "idle"} = issue) do
    # case Task.update(task) do
    #   :ok -> %Task{task | state: :doing}
    #   :error -> task
    # end
    # new_task = {:noreply, new_task}
    Kanban.State.put(issue.title, "doing")
    {:noreply, %Issue{issue | state: "doing"}}
  end

  @impl GenServer
  def handle_cast({:transition, :finish}, %Issue{state: "doing"} = issue) do
    # Save to external storage
    Kanban.State.put(issue.title, "done")
    {:noreply, %Issue{issue | state: "done"}}
    # {:stop, :normal, %Issue{issue | state: "done"}}
  end

  @impl GenServer
  def handle_cast({:transition, transition}, %Issue{state: state} = issue) do
    Logger.warn(inspect({:error, {:not_allowed, transition, state}}))
    {:noreply, issue}
  end

  @impl GenServer
  def handle_call(:state, _from, %Issue{state: state} = issue) do
    {:reply, state, issue}
  end
end
