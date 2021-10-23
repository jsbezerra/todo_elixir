defmodule TodoCacheTest do
  use ExUnit.Case

  setup_all do
    {:ok, todo_system_pid} = Todo.System.start_link()
    {:ok, todo_system_pid: todo_system_pid}
  end

  test "server_process" do
    bob_pid = Todo.Cache.server_process("bob")

    assert bob_pid != Todo.Cache.server_process("alice")
    assert bob_pid == Todo.Cache.server_process("bob")
  end

  test "to-do operations" do
    jane = Todo.Cache.server_process("jane")
    Todo.Server.add_entry(jane, %{date: ~D[2018-12-19], title: "Dentist"})
    entries = Todo.Server.entries(jane, ~D[2018-12-19])

    assert [%{date: ~D[2018-12-19], title: "Dentist"}] = entries
  end

  test "persistence", context do
    john = Todo.Cache.server_process("john")
    Todo.Server.add_entry(john, %{date: ~D[2018-12-20], title: "Shopping"})
    assert 1 == length(Todo.Server.entries(john, ~D[2018-12-20]))

    Supervisor.terminate_child(context.todo_system_pid, Todo.Cache)
    Supervisor.restart_child(context.todo_system_pid, Todo.Cache)

    entries =
      "john"
      |> Todo.Cache.server_process()
      |> Todo.Server.entries(~D[2018-12-20])

    assert [%{date: ~D[2018-12-20], title: "Shopping"}] = entries
  end

  test "update_entry" do
    maria = Todo.Cache.server_process("maria")
    Todo.Server.add_entry(maria, %{date: ~D[2018-12-20], title: "Shopping"})
    Todo.Server.add_entry(maria, %{date: ~D[2018-12-19], title: "Dentist"})
    Todo.Server.add_entry(maria, %{date: ~D[2018-12-19], title: "Movies"})
    Todo.Server.update_entry(maria, %{title: "Updated shopping", date: ~D[2018-12-20], id: 1})

    assert length(Todo.Server.entries(maria)) === 3
    assert [%{title: "Updated shopping"}] = Todo.Server.entries(maria, ~D[2018-12-20])
  end

  test "delete_entry" do
    caleb = Todo.Cache.server_process("Caleb")
    Todo.Server.add_entry(caleb, %{date: ~D[2018-12-19], title: "Dentist"})
    Todo.Server.add_entry(caleb, %{date: ~D[2018-12-20], title: "Shopping"})
    Todo.Server.add_entry(caleb, %{date: ~D[2018-12-19], title: "Movies"})
    Todo.Server.delete_entry(caleb, 2)

    assert length(Todo.Server.entries(caleb)) == 2
    assert Todo.Server.entries(caleb, ~D[2018-12-20]) == []
  end
end
