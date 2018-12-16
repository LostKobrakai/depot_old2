defmodule Depot.Adapters.CommonTest do
  @moduledoc """
  In Memory implementation for `Depot.Adapter`
  """
  use ExUnit.Case, async: true
  use ExUnitProperties
  alias Depot.Adapters

  for adapter <- [Adapters.InMemory, Adapters.Local] do
    describe "#{adapter}" do
      setup do
        adapter = unquote(adapter)
        {:ok, config} = setup_adapter(adapter)
        {:ok, adapter: adapter, config: config}
      end

      property "any non concurrent write can be read",
               %{adapter: adapter, config: config} do
        check all path <- path(), content <- file_content() do
          :ok = adapter.write(config, path, content)
          {:ok, read} = adapter.read(config, path)

          assert IO.iodata_to_binary(content) == IO.iodata_to_binary(read)
        end
      end

      property "updating a file changes it's content",
               %{adapter: adapter, config: config} do
        check all path <- path(),
                  content <- file_content(),
                  content_2 <- file_content(),
                  IO.iodata_to_binary(content) != IO.iodata_to_binary(content_2) do
          :ok = adapter.write(config, path, content)
          {:ok, read} = adapter.read(config, path)
          :ok = adapter.update(config, path, content_2)
          {:ok, read_updated} = adapter.read(config, path)

          assert IO.iodata_to_binary(content) == IO.iodata_to_binary(read)
          assert IO.iodata_to_binary(content_2) == IO.iodata_to_binary(read_updated)
          assert IO.iodata_to_binary(read) != IO.iodata_to_binary(read_updated)
        end
      end

      property "deleted files cannot be read again",
               %{adapter: adapter, config: config} do
        check all path <- path(), content <- file_content() do
          :ok = adapter.write(config, path, content)
          {:ok, _} = adapter.read(config, path)
          :ok = adapter.delete(config, path)

          assert {:error, _} = adapter.read(config, path)
        end
      end

      property "copy file",
               %{adapter: adapter, config: config} do
        check all source <- path(),
                  destination <- path(),
                  content <- file_content(),
                  source != destination do
          :ok = adapter.write(config, source, content)
          {:error, _} = adapter.read(config, destination)
          :ok = adapter.copy(config, source, destination)
          {:ok, source_content} = adapter.read(config, source)
          {:ok, destination_content} = adapter.read(config, destination)

          assert IO.iodata_to_binary(content) == IO.iodata_to_binary(source_content)
          assert IO.iodata_to_binary(content) == IO.iodata_to_binary(destination_content)
        end
      end

      property "rename file",
               %{adapter: adapter, config: config} do
        check all source <- path(),
                  destination <- path(),
                  content <- file_content(),
                  source != destination do
          :ok = adapter.write(config, source, content)
          {:error, _} = adapter.read(config, destination)
          :ok = adapter.rename(config, source, destination)
          {:ok, destination_content} = adapter.read(config, destination)

          assert {:error, _} = adapter.read(config, source)
          assert IO.iodata_to_binary(content) == IO.iodata_to_binary(destination_content)
        end
      end
    end
  end

  defp setup_adapter(Adapters.InMemory) do
    {:ok, pid} = start_supervised(Adapters.InMemory)
    {:ok, %{pid: pid}}
  end

  defp setup_adapter(Adapters.Local) do
    {:ok, path} = Briefly.create(directory: true)
    {:ok, %{root: path}}
  end

  defp path do
    gen all segments <- list_of(dir_or_rootname(), min_length: 1, max_length: 10),
            maybe_extention <- one_of([extention(), constant("")]) do
      segments
      |> Path.join()
      |> Kernel.<>(maybe_extention)
    end
  end

  defp dir_or_rootname do
    string(?a..?z, min_length: 1, max_length: 200)
  end

  defp extention do
    gen all extname <- string(?a..?z, min_length: 1, max_length: 4) do
      ".#{extname}"
    end
  end

  defp file_content do
    gen(all content <- iodata(), content != [0], do: content)
  end
end
