defmodule Todo do
  defstruct auto_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %Todo{},
      &add_entry(&2, &1)
    )
  end

  def add_entry(todo, entry) do
    entry = Map.put(entry, :id, todo.auto_id)

    new_entries = Map.put(todo.entries, todo.auto_id, entry)

    %Todo{todo | entries: new_entries, auto_id: todo.auto_id + 1}
  end

  def entries(todo) do
    todo.entries
  end

  def entries(todo, date) do
    todo.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def delete_entry(todo, entry_id) do
    %Todo{todo | entries: Map.delete(todo.entries, entry_id)}
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

  defimpl Collectable, for: Todo do
    def into(original) do
      {original, &into_callback/2}
    end

    defp into_callback(todo, {:cont, entry}) do
      Todo.add_entry(%Todo{} = todo, entry)
    end

    defp into_callback(%Todo{} = todo, :done), do: todo
    defp into_callback(%Todo{} = _, :halt), do: :ok
  end
end

defmodule TodoServer do
  def start do
    spawn(fn -> loop(Todo.new()) end)
  end

  defp loop(todo) do
    new_todo =
      receive do
        message -> process_message(todo, message)
      end

    loop(new_todo)
  end

  def add_entry(todo_server, new_entry) do
    send(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server) do
    send(todo_server, {:entries, self()})

    receive do
      {:todo_entries, entries} -> entries
    after
      5000 -> {:error, :timeout}
    end
  end

  def entries(todo_server, date) do
    send(todo_server, {:entries, self(), date})

    receive do
      {:todo_entries, entries} -> entries
    after
      5000 -> {:error, :timeout}
    end
  end

  def update_entry(todo_server, entry) do
    send(todo_server, {:update_entry, entry})
  end

  def delete_entry(todo_server, entry_id) do
    send(todo_server, {:delete_entry, entry_id})
  end

  defp process_message(todo, {:add_entry, new_entry}) do
    Todo.add_entry(todo, new_entry)
  end

  defp process_message(todo, {:entries, caller}) do
    send(caller, {:todo_entries, Todo.entries(todo)})
    todo
  end

  defp process_message(todo, {:entries, caller, date}) do
    send(caller, {:todo_entries, Todo.entries(todo, date)})
    todo
  end

  defp process_message(todo, {:update_entry, entry}) do
    Todo.update_entry(todo, entry)
  end

  defp process_message(todo, {:delete_entry, entry_id}) do
    Todo.delete_entry(todo, entry_id)
  end
end
