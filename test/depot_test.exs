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

  test "update file", %{config: config} do
    Depot.write(config, "test.txt", "hello")
    Depot.update(config, "test.txt", "updated")
    assert {:ok, "updated"} = Depot.read(config, "test.txt")
  end

  test "delete file", %{config: config} do
    Depot.write(config, "test.txt", "hello")
    Depot.delete(config, "test.txt")
    assert {:error, _} = Depot.read(config, "test.txt")
  end

  test "copy file", %{config: config} do
    Depot.write(config, "test.txt", "hello")
    Depot.copy(config, "test.txt", "test_2.txt")
    assert {:ok, "hello"} = Depot.read(config, "test_2.txt")
  end

  test "has file", %{config: config} do
    Depot.write(config, "test.txt", "hello")
    assert Depot.has?(config, "test.txt")
    refute Depot.has?(config, "test_2.txt")
  end

  defp setup_adapter(Adapters.InMemory) do
    {:ok, pid} = start_supervised(Adapters.InMemory)
    {:ok, %{pid: pid}}
  end
end
