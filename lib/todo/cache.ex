defmodule Todo.Cache do
  use GenServer

  def start do
    GenServer.start(__MODULE__, nil)
  end

  def server_process(cache_pid, list_name) do
    GenServer.call(cache_pid, {:server_process, list_name})
  end

  @impl GenServer
  def init(_) do
    Todo.File.start()
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:server_process, list_name}, _, servers) do
    case Map.fetch(servers, list_name) do
      {:ok, server} ->
        {:reply, server, servers}

      :error ->
        {:ok, new_server} = Todo.Server.start(list_name)
        {:reply, new_server, Map.put(servers, list_name, new_server)}
    end
  end
end
