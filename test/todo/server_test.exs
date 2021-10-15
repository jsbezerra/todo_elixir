defmodule Todo.Server.Test do
  use ExUnit.Case
  doctest Todo.Server

  test "newly created todo has no entries" do
    {:ok, pid} = Todo.Server.start()
    assert length(Todo.Server.entries(pid)) === 0
  end

  test "new entries are persisted" do
    {:ok, pid} = Todo.Server.start()
    Todo.Server.add_entry(pid, %{date: ~D[2018-12-19], title: "Dentist"})
    Todo.Server.entries(pid)
    assert length(Todo.Server.entries(pid)) === 1

    Todo.Server.add_entry(pid, %{date: ~D[2018-12-20], title: "Office"})
    assert length(Todo.Server.entries(pid)) === 2
  end

  test "retrieve entries by date" do
    {:ok, pid} = Todo.Server.start()

    Todo.Server.add_entry(pid, %{date: ~D[2018-12-19], title: "Dentist"})
    Todo.Server.add_entry(pid, %{date: ~D[2018-12-20], title: "Office"})

    assert [%{id: 2, date: ~D[2018-12-20], title: "Office"}] = Todo.Server.entries(pid, ~D[2018-12-20])
  end

  test "delete entries" do
    {:ok, pid} = Todo.Server.start()
    Todo.Server.add_entry(pid, %{date: ~D[2018-12-19], title: "Dentist"})
    Todo.Server.add_entry(pid, %{date: ~D[2018-12-20], title: "Office"})

    assert [
             %{id: 1, date: ~D[2018-12-19], title: "Dentist"},
             %{id: 2, date: ~D[2018-12-20], title: "Office"}
           ] = Todo.Server.entries(pid)

    Todo.Server.delete_entry(pid, 2)

    assert [%{id: 1, date: ~D[2018-12-19], title: "Dentist"}] = Todo.Server.entries(pid)
  end

  test "update entry" do
    {:ok, pid} = Todo.Server.start()
    Todo.Server.add_entry(pid, %{date: ~D[2018-12-19], title: "Dentist"})
    Todo.Server.add_entry(pid, %{date: ~D[2018-12-20], title: "Office"})

    assert [
             %{id: 1, date: ~D[2018-12-19], title: "Dentist"},
             %{id: 2, date: ~D[2018-12-20], title: "Office"}
           ] = Todo.Server.entries(pid)

    new_entry = %{id: 1, date: ~D[2018-12-21], title: "Not Dentist Anymore"}
    Todo.Server.update_entry(pid, new_entry)

    assert [^new_entry, %{id: 2, date: ~D[2018-12-20], title: "Office"}] =
             Todo.Server.entries(pid)
  end
end
