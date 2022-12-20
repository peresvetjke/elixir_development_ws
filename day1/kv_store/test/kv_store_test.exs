defmodule KVStoreTest do
  use ExUnit.Case
  doctest KVStore

  setup do
    {:ok, pid} = KVStore.start_link(%{a: 1})
    {:ok, pid: pid}
  end

  test "get", context do
    assert KVStore.get(context[:pid], :a) == 1
  end

  test "put", context do
    IO.inspect(KVStore.get(context[:pid], :b))
    assert KVStore.put(context[:pid], {:b, 2}) == :ok
    assert KVStore.get(context[:pid], :b) == 2
  end

  test "another get", context do
    IO.inspect(KVStore.get(context[:pid], :b))
  end
end
