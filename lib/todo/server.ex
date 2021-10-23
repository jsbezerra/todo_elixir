defmodule Todo.Server do
  use GenServer, restart: :temporary

  def start_link(name) do
    GenServer.start_link(Todo.Server, name, name: via_tuple(name))
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

  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end

  @impl GenServer
  def init(name) do
    IO.puts("Starting to-do server for #{name}")
    {:ok, {name, Todo.File.get(name) || Todo.List.new()}}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {name, todo}) do
    modified_list = Todo.List.add_entry(todo, new_entry)
    Todo.File.store(name, modified_list)
    {:noreply, {name, modified_list}}
  end

  @impl GenServer
  def handle_cast({:update_entry, entry}, {name, todo}) do
    {:noreply, {name, Todo.List.update_entry(todo, entry)}}
  end

  @impl GenServer
  def handle_cast({:delete_entry, entry_id}, {name, todo}) do
    {:noreply, {name, Todo.List.delete_entry(todo, entry_id)}}
  end

  @impl GenServer
  def handle_call({:entries}, _, {name, todo}) do
    {:reply, Todo.List.entries(todo), {name, todo}}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, {name, todo}) do
    {:reply, Todo.List.entries(todo, date), {name, todo}}
  end
end
