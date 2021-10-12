defmodule TodoTest do
  use ExUnit.Case
  doctest Todo

  test "newly created todo has no entries" do
    {:ok, pid} = TodoServer.start()
    entries = TodoServer.entries(pid)
    assert length(entries) == 0
  end

  test "new entries are persisted" do
    {:ok, pid} = TodoServer.start()
    TodoServer.add_entry(pid, %{date: ~D[2018-12-19], title: "Dentist"})
    TodoServer.entries(pid)
    assert length(TodoServer.entries(pid)) == 1

    TodoServer.add_entry(pid, %{date: ~D[2018-12-20], title: "Office"})
    assert length(TodoServer.entries(pid)) == 2
  end

  test "retrieve entries by date" do
    {:ok, pid} = TodoServer.start()
    TodoServer.add_entry(pid, %{date: ~D[2018-12-19], title: "Dentist"})
    TodoServer.add_entry(pid, %{date: ~D[2018-12-20], title: "Office"})
    entries = [head | _] = TodoServer.entries(pid, ~D[2018-12-20])
    assert length(entries) === 1
    assert head.title === "Office"
    assert head.id === 2
    assert head.date === ~D[2018-12-20]
  end

  test "delete entries" do
    {:ok, pid} = TodoServer.start()
    TodoServer.add_entry(pid, %{date: ~D[2018-12-19], title: "Dentist"})
    TodoServer.add_entry(pid, %{date: ~D[2018-12-20], title: "Office"})
    assert length(TodoServer.entries(pid)) == 2

    TodoServer.delete_entry(pid, 2)
    entries = [head | _] = TodoServer.entries(pid)
    assert length(entries) === 1
    assert head.title === "Dentist"
    assert head.id === 1
    assert head.date === ~D[2018-12-19]
  end
end
