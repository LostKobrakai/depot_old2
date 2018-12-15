defmodule DepotTest do
  use ExUnit.Case, async: true
  alias Depot.Adapters

  setup do
    {:ok, config} = setup_adapter(Adapters.InMemory)
    config = Map.put(config, :adapter, Adapters.InMemory)
    {:ok, config: config}
  end

  test "write file", %{config: config} do
    assert :ok = Depot.write(config, "test.txt", "hello")
  end

  test "read file", %{config: config} do
    Depot.write(config, "test.txt", "hello")
    assert {:ok, "hello"} = Depot.read(config, "test.txt")
  end

  defp setup_adapter(Adapters.InMemory) do
    {:ok, pid} = start_supervised(Adapters.InMemory)
    {:ok, %{pid: pid}}
  end
end
