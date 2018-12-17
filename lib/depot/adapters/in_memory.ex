defmodule Depot.Adapters.InMemory do
  @moduledoc """
  In Memory implementation for `Depot.Adapter`
  """
  @behaviour Depot.Adapter
  use Agent
  alias Depot.Util

  def start_link(opts) do
    opts =
      Enum.reduce(opts, [], fn
        {:name, name}, opts -> [{:name, name} | opts]
      end)

    Agent.start_link(fn -> %{} end, opts)
  end

  @impl true
  def write(%{pid: pid}, path, contents, _opts \\ []) do
    path = Util.normalize_path(path)
    Agent.update(pid, &Map.put(&1, path, contents))
  end

  @impl true
  def read(%{pid: pid}, path, _opts \\ []) do
    path = Util.normalize_path(path)

    case Agent.get(pid, &Map.fetch(&1, path)) do
      {:ok, _} = success -> success
      :error -> {:error, :nofile}
    end
  end

  @impl true
  def update(config, path, contents, opts \\ []) do
    path = Util.normalize_path(path)
    write(config, path, contents, opts)
  end

  @impl true
  def delete(%{pid: pid}, path) do
    path = Util.normalize_path(path)
    Agent.update(pid, &Map.delete(&1, path))
  end

  @impl true
  def copy(%{pid: pid}, source, destination) do
    source = Util.normalize_path(source)
    destination = Util.normalize_path(destination)

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
    source = Util.normalize_path(source)
    destination = Util.normalize_path(destination)

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

  @impl true
  def has?(%{pid: pid}, path) do
    path = Util.normalize_path(path)

    Agent.get(pid, fn state ->
      Map.has_key?(state, path)
    end)
  end
end
