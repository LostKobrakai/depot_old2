defmodule Depot.Adapters.Local do
  @moduledoc """
  Local filesystem implementation for `Depot.Adapter`
  """
  @behaviour Depot.Adapter

  @impl true
  def write(config, path, contents, _opts \\ []) do
    path = full_path(config, path)
    :ok = File.mkdir_p(Path.dirname(path))
    File.write(path, contents)
  end

  @impl true
  def read(config, path, _opts \\ []) do
    File.read(full_path(config, path))
  end

  @impl true
  def update(config, path, contents, opts \\ []) do
    write(config, path, contents, opts)
  end

  @impl true
  def delete(config, path) do
    path = full_path(config, path)

    with :ok <- File.rm(path) do
      recursively_delete_empty_folders(path, config)
    end
  end

  @impl true
  def copy(config, source, destination) do
    source = full_path(config, source)
    full_destination = full_path(config, destination)
    :ok = File.mkdir_p(Path.dirname(full_destination))

    case File.cp(source, full_destination, fn _, _ -> false end) do
      :ok ->
        :ok

      result ->
        recursively_delete_empty_folders(destination, config)
        result
    end
  end

  @impl true
  def rename(config, source, destination) do
    source = full_path(config, source)
    full_destination = full_path(config, destination)
    :ok = File.mkdir_p(Path.dirname(full_destination))

    case File.rename(source, full_destination) do
      :ok ->
        :ok

      result ->
        recursively_delete_empty_folders(destination, config)
        result
    end
  end

  defp full_path(%{root: root}, path) do
    Path.join([root, path])
  end

  defp recursively_delete_empty_folders(path, config) do
    dir = Path.dirname(path)

    with true <- dir != ".",
         :ok <- File.rmdir(full_path(config, dir)) do
      recursively_delete_empty_folders(dir, config)
    else
      _ -> :ok
    end
  end
end
