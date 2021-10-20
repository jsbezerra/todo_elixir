defmodule Todo.Server.Test do
  use ExUnit.Case
  doctest Todo.Server

  setup_all do
    case Todo.File.start_link(nil) do
      {:ok, _} -> :ok
      _ -> :error
    end

    on_exit(fn -> Process.exit(Process.whereis(Todo.File), :kill) end)
  end

  test "newly created todo has no entries" do
    File.rm(".persist/list_1")
    {:ok, pid} = Todo.Server.start("list_1")
    assert length(Todo.Server.entries(pid)) === 0
  end

  test "new entries are persisted" do
    File.rm(".persist/list_2")
    {:ok, pid} = Todo.Server.start("list_2")
    Todo.Server.add_entry(pid, %{date: ~D[2018-12-19], title: "Dentist"})
    assert length(Todo.Server.entries(pid)) === 1
    assert length(Todo.Server.entries(pid)) === 1

    Todo.Server.add_entry(pid, %{date: ~D[2018-12-20], title: "Office"})
    assert length(Todo.Server.entries(pid)) === 2
  end

  test "retrieve entries by date" do
    File.rm(".persist/list_3")
    {:ok, pid} = Todo.Server.start("list_3")

    Todo.Server.add_entry(pid, %{date: ~D[2018-12-19], title: "Dentist"})
    Todo.Server.add_entry(pid, %{date: ~D[2018-12-20], title: "Office"})

    assert [%{id: 2, date: ~D[2018-12-20], title: "Office"}] =
             Todo.Server.entries(pid, ~D[2018-12-20])
  end

  test "delete entries" do
    File.rm(".persist/list_4")
    {:ok, pid} = Todo.Server.start("list_4")
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
    File.rm(".persist/list_5")
    {:ok, pid} = Todo.Server.start("list_5")
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
