defmodule KVStore do
  use GenServer

  # Client

  @spec start_link :: GenServer.on_start()
  @spec start_link(map) :: GenServer.on_start()
  def start_link(map \\ %{}) do
    GenServer.start_link(__MODULE__, map)
  end

  @spec get(pid, any) :: any
  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  @spec put(pid, {any, any}) :: :ok
  def put(pid, {key, value}) do
    GenServer.cast(pid, {:put, key, value})
  end

  # Callbacks

  @impl GenServer
  def init(%{} = map) do
    {:ok, map}
  end

  @impl GenServer
  def handle_call({:get, key}, _from, map) do
    {:reply, Map.get(map, key), map}
  end

  @impl GenServer
  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end
end
