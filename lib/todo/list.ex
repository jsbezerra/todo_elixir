defmodule Todo.List do
  defstruct auto_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %Todo.List{},
      &add_entry(&2, &1)
    )
  end

  def add_entry(list, entry) do
    entry = Map.put(entry, :id, list.auto_id)

    new_entries = Map.put(list.entries, list.auto_id, entry)

    %Todo.List{list | entries: new_entries, auto_id: list.auto_id + 1}
  end

  def entries(list) do
    list.entries
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def entries(list, date) do
    list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def delete_entry(list, entry_id) do
    %Todo.List{list | entries: Map.delete(list.entries, entry_id)}
  end

  def update_entry(list, %{} = new_entry) do
    update_entry(list, new_entry.id, fn _ -> new_entry end)
  end

  def update_entry(list, entry_id, updater_lambda) do
    case Map.fetch(list.entries, entry_id) do
      :error ->
        list

      {:ok, old_entry} ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater_lambda.(old_entry)
        new_entries = Map.put(list.entries, new_entry.id, new_entry)
        %Todo.List{list | entries: new_entries}
    end
  end

  def size(list) do
    length(Todo.List.entries(list))
  end

  defimpl Collectable, for: Todo.List do
    def into(original) do
      {original, &into_callback/2}
    end

    defp into_callback(list, {:cont, entry}) do
      Todo.List.add_entry(%Todo.List{} = list, entry)
    end

    defp into_callback(%Todo.List{} = list, :done), do: list
    defp into_callback(%Todo.List{} = _, :halt), do: :ok
  end
end
