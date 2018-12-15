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
        check all path <- path(), content <- iodata() do
          :ok = adapter.write(config, path, content)
          {:ok, read} = adapter.read(config, path)

          assert IO.iodata_to_binary(content) == IO.iodata_to_binary(read)
        end
      end

      property "deleted files cannot be read again",
               %{adapter: adapter, config: config} do
        check all path <- path(), content <- iodata() do
          :ok = adapter.write(config, path, content)
          {:ok, _} = adapter.read(config, path)
          :ok = adapter.delete(config, path)

          assert {:error, _} = adapter.read(config, path)
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
    gen all segments <- list_of(dir_or_rootname(), min_length: 1, max_length: 15),
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
end