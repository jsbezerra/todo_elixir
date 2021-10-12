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
    |> Enum.map(fn {_, entry} -> entry end)
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
  use GenServer

  def start do
    GenServer.start(__MODULE__, nil)
  end

  def add_entry(pid, new_entry) do
    GenServer.cast(pid, {:add_entry, new_entry})
  end

  def entries(pid) do
    GenServer.call(pid, {:entries})
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  def update_entry(pid, entry) do
    GenServer.cast(pid, {:update_entry, entry})
  end

  def delete_entry(pid, entry_id) do
    GenServer.cast(pid, {:delete_entry, entry_id})
  end

  @impl GenServer
  def init(_) do
    {:ok, Todo.new}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, todo) do
    {:noreply, Todo.add_entry(todo, new_entry)}
  end

  @impl GenServer
  def handle_cast({:update_entry, entry}, todo) do
    {:noreply, Todo.update_entry(todo, entry)}
  end

  @impl GenServer
  def handle_cast({:delete_entry, entry_id}, todo) do
    {:noreply, Todo.delete_entry(todo, entry_id)}
  end

  @impl GenServer
  def handle_call({:entries}, _, todo) do
    {:reply, Todo.entries(todo), todo}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, todo) do
    {:reply, Todo.entries(todo, date), todo}
  end
end
