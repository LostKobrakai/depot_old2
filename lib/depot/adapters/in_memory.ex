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

  @impl true
  def write(%{pid: pid}, path, contents, _opts \\ []) do
    Agent.update(pid, &Map.put(&1, path, contents))
  end

  @impl true
  def read(%{pid: pid}, path, _opts \\ []) do
    case Agent.get(pid, &Map.fetch(&1, path)) do
      {:ok, _} = success -> success
      :error -> {:error, :nofile}
    end
  end

  @impl true
  def update(config, path, contents, opts \\ []) do
    write(config, path, contents, opts)
  end

  @impl true
  def delete(%{pid: pid}, path) do
    Agent.update(pid, &Map.delete(&1, path))
  end

  @impl true
  def copy(%{pid: pid}, source, destination) do
    Agent.get_and_update(pid, fn state ->
      with {:ok, contents} <- Map.fetch(state, source),
           :error <- Map.fetch(state, destination) do
        {:ok, Map.put(state, destination, contents)}
      else
        :error -> {{:error, :nosource}, state}
        {:ok, _} -> {{:error, :destinationexists}, state}
      end
    end)
  end

  @impl true
  def rename(%{pid: pid}, source, destination) do
    Agent.get_and_update(pid, fn state ->
      with {contents, state} when not is_nil(contents) <- Map.pop(state, source),
           :error <- Map.fetch(state, destination) do
        {:ok, Map.put(state, destination, contents)}
      else
        :error -> {{:error, :nosource}, state}
        {:ok, _} -> {{:error, :destinationexists}, state}
      end
    end)
  end
end
