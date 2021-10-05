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

  def update_entry(todo, %{} = new_entry) do
    update_entry(todo, new_entry.id, fn _ -> new_entry end)
  end

  def update_entry(todo, entry_id, updater_lambda) do
    case Map.fetch(todo.entries, entry_id) do
      :error ->
        todo

      {:ok, old_entry} ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater_lambda.(old_entry)
        new_entries = Map.put(todo.entries, new_entry.id, new_entry)
        %Todo{todo | entries: new_entries}
    end
  end
end
