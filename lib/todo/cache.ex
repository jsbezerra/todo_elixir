defmodule Todo.Cache do
  use GenServer

  @impl GenServer
  def init(_), do: {:ok, %{}}

  @impl GenServer
  def handle_call({:server_process, list_name}, _, servers) do
    case Map.fetch(servers, list_name) do
      {:ok, server} ->
        {:reply, server, servers}

      :error ->
        {:ok, new_server} = Todo.Server.start()
        {:reply, new_server, Map.put(servers, list_name, new_server)}
    end
  end

  def start do
    GenServer.start(__MODULE__, nil)
  end

  def server_process(cache_pid, list_name) do
    GenServer.call(cache_pid, {:server_process, list_name})
  end
end
