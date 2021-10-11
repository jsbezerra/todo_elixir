defmodule TodoTest do
  use ExUnit.Case
  doctest Todo

  test "newly created todo has no entries" do
    server = TodoServer.start()
    entries = TodoServer.entries(server)
    assert map_size(entries) == 0
  end

  test "new entries are persisted" do
    server = TodoServer.start()
    TodoServer.add_entry(server, %{date: ~D[2018-12-19], title: "Dentist"})
    TodoServer.entries(server)
    assert map_size(TodoServer.entries(server)) == 1

    TodoServer.add_entry(server, %{date: ~D[2018-12-20], title: "Office"})
    assert map_size(TodoServer.entries(server)) == 2
  end
end
