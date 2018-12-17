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
  Start the adapter if it needs a long running process
  """
  @callback child_spec(term) :: Supervisor.child_spec()

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
  Updates `content` of the file `path`.

  Returns `:ok` if successful, or `{:error, reason}` if an error occurs.

  `content` must be `iodata` (a list of bytes or a binary).

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

  @doc """
  Copies the contents in `source` to `destination`.

  If a file already exists in the destination, the function must abort.

  The function returns `:ok` in case of success, returns `{:error, reason}` otherwise.
  """
  @callback copy(config, Path.t(), Path.t()) :: :ok | {:error, error_reason}

  @doc """
  Renames the `source` file to `destination` file. It can be used to move files (and directories) between directories. If moving a file, you must fully specify the `destination` filename, it is not sufficient to simply specify its directory.

  Returns `:ok` in case of success, `{:error, reason}` otherwise.

  If the filesystem does not support atomic renaming you can return `:unsupported`
  and the action will fallback to `c:copy/3` and `c:delete/2`.
  """
  @callback rename(config, Path.t(), Path.t()) :: :ok | {:error, error_reason} | :unsupported

  @doc """
  Returns true if a file exists at the given path.
  """
  @callback has?(config, Path.t()) :: boolean

  @optional_callbacks child_spec: 1
end
