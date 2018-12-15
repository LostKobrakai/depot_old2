defmodule Depot.Adapter do
  @moduledoc """
  The behaviour for adapters used by `Depot`.

  There are some things to be expected of adapters to ensure switching between
  different implementions is as seemless as possible:

  ## Folders

  Folders are expected to be created/cleaned up transparently, as
  there are many filesystems without a concept of empty folders.
  """

  @typedoc "A module implementing the `Depot.Adapter` behaviour."
  @type t :: module

  @typedoc "For details on errors please consult the individual apapters' documentation."
  @type error_reason :: term

  @typedoc "Configuration data for the adapter."
  @type config :: %{optional(atom) => term}

  @typedoc "Additional options for the individual functions."
  @type opts :: Keyword.t()

  @doc """
  Writes `content` to the file `path`.

  The file must be created if it does not exist. If it exists, the previous
  contents are overwritten. Returns `:ok` if successful, or {:error, reason}
  if an error occurs.

  `content` must be `iodata` (a list of bytes or a binary).

  Missing folders in the `path` are to be created.
  """
  @callback write(config, Path.t(), iodata(), opts) :: :ok | {:error, error_reason}

  @doc """
  Returns `{:ok, content}`, where `content` is a `iodata` data object that contains the contents of path, or `{:error, reason}` if an error occurs.
  """
  @callback read(config, Path.t(), opts) :: {:ok, iodata()} | {:error, error_reason}

  @doc """
  Writes `content` to the existing file `path`.

  This can often times just delegate to `c:write/4`, but offers the opportunity
  to have `c:write/4` create folders, while `c:update/4` does expect the file and
  it's parent folders to be present.
  """
  @callback update(config, Path.t(), iodata(), opts) :: :ok | {:error, error_reason}

  @doc """
  Tries to delete the file path.

  Returns :ok if successful, or {:error, reason} if an error occurs.
  """
  @callback delete(config, Path.t()) :: :ok | {:error, error_reason}
end
