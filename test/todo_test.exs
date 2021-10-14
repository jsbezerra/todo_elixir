defmodule TodoTest do
  use ExUnit.Case
  doctest Todo.Server

  test "newly created todo has no entries" do
    {:ok, pid} = Todo.Server.start()
    entries = Todo.Server.entries(pid)
    assert length(entries) == 0
  end

  test "new entries are persisted" do
    {:ok, pid} = Todo.Server.start()
    Todo.Server.add_entry(pid, %{date: ~D[2018-12-19], title: "Dentist"})
    Todo.Server.entries(pid)
    assert length(Todo.Server.entries(pid)) == 1

    Todo.Server.add_entry(pid, %{date: ~D[2018-12-20], title: "Office"})
    assert length(Todo.Server.entries(pid)) == 2
  end

  test "retrieve entries by date" do
    {:ok, pid} = Todo.Server.start()
    Todo.Server.add_entry(pid, %{date: ~D[2018-12-19], title: "Dentist"})
    Todo.Server.add_entry(pid, %{date: ~D[2018-12-20], title: "Office"})
    entries = [head | _] = Todo.Server.entries(pid, ~D[2018-12-20])
    assert length(entries) === 1
    assert head.title === "Office"
    assert head.id === 2
    assert head.date === ~D[2018-12-20]
  end

  test "delete entries" do
    {:ok, pid} = Todo.Server.start()
    Todo.Server.add_entry(pid, %{date: ~D[2018-12-19], title: "Dentist"})
    Todo.Server.add_entry(pid, %{date: ~D[2018-12-20], title: "Office"})
    assert length(Todo.Server.entries(pid)) == 2

    Todo.Server.delete_entry(pid, 2)
    entries = [head | _] = Todo.Server.entries(pid)
    assert length(entries) === 1
    assert head.title === "Dentist"
    assert head.id === 1
    assert head.date === ~D[2018-12-19]
  end

  test "update entry" do
    {:ok, pid} = Todo.Server.start()
    Todo.Server.add_entry(pid, %{date: ~D[2018-12-19], title: "Dentist"})
    Todo.Server.add_entry(pid, %{date: ~D[2018-12-20], title: "Office"})
    assert length(Todo.Server.entries(pid)) == 2
    [head | _] = Todo.Server.entries(pid)
    assert head.title === "Dentist"
    assert head.id === 1
    assert head.date === ~D[2018-12-19]

    new_entry = %{id: 1, date: ~D[2018-12-21], title: "Not Dentist Anymore"}
    Todo.Server.update_entry(pid, new_entry)
    [head | _] = Todo.Server.entries(pid)
    assert head.title === "Not Dentist Anymore"
    assert head.id === 1
    assert head.date === ~D[2018-12-21]
  end
end
