defmodule Todo.System do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  @impl Supervisor
  def init(_) do
    Supervisor.init(
      [
        Todo.Metrics,
        Todo.ProcessRegistry,
        Todo.File,
        Todo.Cache,
        Todo.Web
      ],
      strategy: :one_for_one
    )
  end
end
