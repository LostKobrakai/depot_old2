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
  def delete(%{root: root} = config, path) do
    path = full_path(config, path)

    with :ok <- File.rm(path) do
      recursively_delete_empty_folders(path, root)
    end
  end

  @impl true
  def copy(%{root: root} = config, source, destination) do
    source = full_path(config, source)
    destination = full_path(config, destination)
    :ok = File.mkdir_p(Path.dirname(destination))

    case File.cp(source, destination, fn _, _ -> false end) do
      :ok ->
        :ok

      result ->
        recursively_delete_empty_folders(destination, root)
        result
    end
  end

  defp full_path(%{root: root}, path) do
    Path.join(root, path)
  end

  defp recursively_delete_empty_folders(path, root) do
    recursively_delete_empty_folders(Path.expand(path), Path.expand(root), :expanded)
  end

  defp recursively_delete_empty_folders(path, root, :expanded) do
    dir = Path.dirname(path)

    with true <- dir != Path.dirname(root),
         :ok <- File.rmdir(dir) do
      recursively_delete_empty_folders(dir, root)
    else
      _ -> :ok
    end
  end
end
