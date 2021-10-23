defmodule Todo.File do
  use Supervisor

  @db_folder "./persist"
  @pool_size 3

  def start_link() do
    Supervisor.start_link(__MODULE__, nil)
  end

  def store(key, data) do
    key
    |> choose_worker()
    |> Todo.FileWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker()
    |> Todo.FileWorker.get(key)
  end

  def child_spec(_) do
    %{id: __MODULE__, start: {__MODULE__, :start_link, []}, type: :supervisor}
  end

  # Choosing a worker makes a request to the File server process. There we
  # keep the knowledge about our workers, and return the pid of the corresponding
  # worker. Once this is done, the caller process will talk to the worker directly.
  defp choose_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end

  @impl Supervisor
  def init(_) do
    File.mkdir_p!(@db_folder)

    workers = Enum.map(1..@pool_size, &worker_spec/1)
    Supervisor.init(workers, strategy: :one_for_one)
  end

  defp worker_spec(worker_id) do
    default_worker_spec = {Todo.FileWorker, {@db_folder, worker_id}}
    Supervisor.child_spec(default_worker_spec, id: worker_id)
  end
end
