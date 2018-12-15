defmodule Depot do
  @moduledoc """
  Depot is a filesystem abstraction for elixir providing a unified interface over many implementations. It allows you to swap out filesystems on the fly without needing to rewrite all
  of your application code in the process. It can eliminate vendor-lock in, reduce
  technical debt, and improve the testability of your code.

  This library is based on the ideas of [flysystem](http://flysystem.thephpleague.com/),
  which is a PHP library providing similar functionality.

  ## Architecture

  Depot uses adapters to mediating API incompatibilities between different filesystem
  implementations. Each adapter needs to adhere to the `Depot.Adapter` behaviour
  and is supposed to act by certain constraints detailed in the callback documentation.
  """

  @typedoc "For details on errors please consult the individual apapters' documentation."
  @type error_reason :: term

  @typedoc "Configuration of the filesystem to be used."
  @type config :: %{required(:adapter) => Depot.Adapter.t(), optional(atom) => term}

  @typedoc "Additional options for the individual functions."
  @type opts :: Keyword.t()

  @doc """
  Writes `content` to the file `path`.

  The file is created if it does not exist. If it exists, the previous contents are overwritten. Returns `:ok` if successful, or `{:error, reason}` if an error occurs.

  content must be iodata (a list of bytes or a binary). Setting the encoding for this function has no effect.
  """
  @spec write(config, Path.t(), iodata(), opts) :: :ok | {:error, error_reason}
  def write(%{adapter: adapter} = config, path, contents, opts \\ []) do
    adapter.write(Map.drop(config, [:adapter]), path, contents, opts)
  end

  @doc """
  Returns `{:ok, content}`, where `content` is a `iodata` data object that contains the contents of path, or `{:error, reason}` if an error occurs.
  """
  @spec read(config, Path.t(), opts) :: {:ok, iodata} | {:error, error_reason}
  def read(%{adapter: adapter} = config, path, opts \\ []) do
    adapter.read(Map.drop(config, [:adapter]), path, opts)
  end

  def delete(%{adapter: adapter} = config, path) do
    adapter.delete(Map.drop(config, [:adapter]), path)
  end
end
