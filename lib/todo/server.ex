defmodule Todo.Server do
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
    {:ok, Todo.List.new}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, todo) do
    {:noreply, Todo.List.add_entry(todo, new_entry)}
  end

  @impl GenServer
  def handle_cast({:update_entry, entry}, todo) do
    {:noreply, Todo.List.update_entry(todo, entry)}
  end

  @impl GenServer
  def handle_cast({:delete_entry, entry_id}, todo) do
    {:noreply, Todo.List.delete_entry(todo, entry_id)}
  end

  @impl GenServer
  def handle_call({:entries}, _, todo) do
    {:reply, Todo.List.entries(todo), todo}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, todo) do
    {:reply, Todo.List.entries(todo, date), todo}
  end
end
