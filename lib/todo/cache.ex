defmodule Todo.Cache do
  use GenServer

  def start_link(_) do
    IO.puts("Starting to-do cache.")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def server_process(list_name) do
    GenServer.call(__MODULE__, {:server_process, list_name})
  end

  @impl GenServer
  def init(_) do
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
