defmodule KeyValueStoreTest do
  use ExUnit.Case
  doctest KeyValueStore

  test "adding and retrieving values from KeyValueStore" do
    {:ok, pid} = KeyValueStore.start()
    KeyValueStore.put(pid, :key, :value)
    KeyValueStore.put(pid, :key2, :value2)
    assert KeyValueStore.get(pid, :key) === :value
    assert KeyValueStore.get(pid, :key2) === :value2
    assert KeyValueStore.get(pid, :key3) === nil
  end
end