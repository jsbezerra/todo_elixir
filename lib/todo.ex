defmodule Todo do
  defstruct auto_id: 1, entries: %{}

  def new() do
    %Todo{}
  end

  def add_entry(todo, entry) do
    entry = Map.put(entry, :id, todo.auto_id)

    new_entries = Map.put(todo.entries, todo.auto_id, entry)

    %Todo{todo | entries: new_entries, auto_id: todo.auto_id + 1}
  end

  def entries(todo, date) do
    todo.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end
end
