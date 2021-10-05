defmodule Todo do

  def new() do
    Dictionary.new()
  end

  def add_entry(todo, date, title) do
    Dictionary.add(todo, date, title)
  end

  def entries(todo, date) do
    Map.get(todo, date)
  end
end
