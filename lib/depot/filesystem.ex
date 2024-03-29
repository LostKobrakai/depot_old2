defmodule Depot.Filesystem do
  @moduledoc """
  Convenience module to represent a filesystem configuration as a module.
  """
  use Supervisor

  defmacro __using__(opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)

    quote bind_quoted: [otp_app: otp_app] do
      def write(path, contents, opts \\ []) do
        Depot.write(config(), path, contents, opts)
      end

      def read(path, opts \\ []) do
        Depot.read(config(), path, opts)
      end

      def update(path, contents, opts \\ []) do
        Depot.update(config(), path, contents, opts)
      end

      def delete(path) do
        Depot.delete(config(), path)
      end

      def copy(source, destination) do
        Depot.copy(config(), source, destination)
      end

      def rename(source, destination) do
        Depot.rename(config(), source, destination)
      end

      def has?(path) do
        Depot.has?(config(), path)
      end

      def child_spec(arg) do
        Depot.Filesystem.child_spec(arg_to_args(arg))
        |> Map.put(:id, __MODULE__)
      end

      def start_link(arg) do
        Depot.Filesystem.start_link(arg_to_args(arg))
      end

      def init(config, _), do: config

      defp config do
        Depot.ConfigCache.config(__MODULE__)
      end

      defp arg_to_args(arg) do
        opts = %{
          otp_app: unquote(otp_app),
          module: __MODULE__,
          arg: arg
        }
      end

      defoverridable init: 2
    end
  end

  def start_link(%{module: module} = args) do
    Supervisor.start_link(__MODULE__, args, name: module)
  end

  def init(%{otp_app: otp_app, module: module, arg: arg}) do
    config =
      Application.fetch_env!(otp_app, module)
      |> module.init(arg)
      |> Map.new()

    unless Code.ensure_loaded?(config.adapter) do
      raise "Adapter #{config.adapter} not available."
    end

    children =
      if function_exported?(config.adapter, :child_spec, 1) do
        name = Module.concat(module, Adapter)
        config = Map.put(config, :pid, name)

        [
          {config.adapter, [name: name]},
          {Depot.ConfigCache, {module, config}}
        ]
      else
        [
          {Depot.ConfigCache, {module, config}}
        ]
      end

    Supervisor.init(children, strategy: :one_for_all)
  end
end
