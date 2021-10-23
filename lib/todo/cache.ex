defmodule Todo.Cache do
  use DynamicSupervisor

  def start_link() do
    IO.puts("Starting to-do cache")
    DynamicSupervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  def server_process(list_name) do
    case start_child(list_name) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  defp start_child(list_name) do
    DynamicSupervisor.start_child(__MODULE__, {Todo.Server, list_name})
  end
end
