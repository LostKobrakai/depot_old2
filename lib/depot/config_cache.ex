defmodule Depot.ConfigCache do
  @moduledoc false
  use GenServer

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  def init({module, config}) do
    :ets.new(module, [:protected, :named_table, read_concurrency: true])
    :ets.insert(module, {:config, config})
    {:ok, config}
  end

  def config(module) do
    [{:config, config}] = :ets.lookup(module, :config)
    config
  end
end
