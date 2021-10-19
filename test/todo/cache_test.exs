defmodule TodoCacheTest do
  use ExUnit.Case

  test "server_process" do
    {:ok, _} = Todo.Cache.start_link(nil)
    bob_pid = Todo.Cache.server_process("bob")

    assert bob_pid != Todo.Cache.server_process("alice")
    assert bob_pid == Todo.Cache.server_process("bob")
  end

  test "to-do operations" do
    {:ok, _} = Todo.Cache.start_link(nil)
    alice = Todo.Cache.server_process("alice")
    Todo.Server.add_entry(alice, %{date: ~D[2018-12-19], title: "Dentist"})
    entries = Todo.Server.entries(alice, ~D[2018-12-19])

    assert [%{date: ~D[2018-12-19], title: "Dentist"}] = entries
  end

  test "persistence" do
    {:ok, cache} = Todo.Cache.start_link(nil)

    john = Todo.Cache.server_process("john")
    Todo.Server.add_entry(john, %{date: ~D[2018-12-20], title: "Shopping"})
    assert 1 == length(Todo.Server.entries(john, ~D[2018-12-20]))

    GenServer.stop(cache)
    {:ok, _} = Todo.Cache.start_link(nil)

    entries =
      Todo.Cache.server_process("john")
      |> Todo.Server.entries(~D[2018-12-20])

    assert [%{date: ~D[2018-12-20], title: "Shopping"}] = entries
  end
end
