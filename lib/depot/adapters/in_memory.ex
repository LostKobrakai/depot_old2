defmodule Depot.Adapters.InMemory do
  @moduledoc """
  In Memory implementation for `Depot.Adapter`
  """
  @behaviour Depot.Adapter
  use Agent

  def start_link(opts) do
    opts =
      Enum.reduce(opts, [], fn
        {:name, name}, opts -> [{:name, name} | opts]
      end)

    Agent.start_link(fn -> %{} end, opts)
  end

  def write(%{pid: pid}, path, contents, _opts \\ []) do
    Agent.update(pid, &Map.put(&1, path, contents))
  end

  def read(%{pid: pid}, path, _opts \\ []) do
    case Agent.get(pid, &Map.fetch(&1, path)) do
      {:ok, _} = success -> success
      :error -> {:error, :nofile}
    end
  end

  def update(config, path, contents, opts \\ []) do
    write(config, path, contents, opts)
  end

  def delete(%{pid: pid}, path) do
    Agent.update(pid, &Map.delete(&1, path))
  end
end
