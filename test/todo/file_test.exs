defmodule Todo.File.Test do
  use ExUnit.Case
  doctest Todo.File

  test "cache successfully starts" do
    case Todo.File.start() do
      {:ok, _} ->
        :ok

      {:error, {reason, _pid}} ->
        assert reason === :already_started
        :ok

      _ ->
        :error
    end
  end
end
