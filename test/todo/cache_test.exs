defmodule Todo.Cache.Test do
  use ExUnit.Case
  doctest Todo.Cache

  test "cache successfully starts" do
    {status, _} = Todo.Cache.start()
    assert status === :ok
  end

  test "create a new server" do
    {:ok, cache_pid} = Todo.Cache.start()
    server1_pid = Todo.Cache.server_process(cache_pid, :list1)
    assert length(Todo.Server.entries(server1_pid)) === 0
  end

  test "persist an entry" do
    {:ok, cache_pid} = Todo.Cache.start()
    places_pid = Todo.Cache.server_process(cache_pid, :places)
    Todo.Server.add_entry(places_pid, %{date: ~D[2018-12-19], title: "Dentist"})

    new_places_pid = Todo.Cache.server_process(cache_pid, :places)
    Todo.Server.add_entry(new_places_pid, %{date: ~D[2018-12-20], title: "Office"})

    groceries_pid = Todo.Cache.server_process(cache_pid, :groceries)
    Todo.Server.add_entry(groceries_pid, %{date: ~D[2018-12-20], title: "Lettuce"})

    assert length(Todo.Server.entries(places_pid)) === 2
    assert length(Todo.Server.entries(groceries_pid)) === 1

    assert places_pid === new_places_pid
    assert places_pid !== groceries_pid
  end
end