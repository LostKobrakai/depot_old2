defmodule Depot.Util do
  def normalize_path(path) do
    path
    |> Path.expand("/")
    |> Path.relative()
  end
end
