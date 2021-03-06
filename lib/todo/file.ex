defmodule Todo.File do
  @db_folder "./persist"
  @pool_size 3

  def store(key, data) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid ->
        Todo.FileWorker.store(worker_pid, key, data)
      end
    )
  end

  def get(key) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid ->
        Todo.FileWorker.get(worker_pid, key)
      end
    )
  end

  def child_spec(_) do
    File.mkdir_p!(@db_folder)

    :poolboy.child_spec(
      __MODULE__,
      [name: {:local, __MODULE__}, worker_module: Todo.FileWorker, size: @pool_size],
      [@db_folder]
    )
  end
end
