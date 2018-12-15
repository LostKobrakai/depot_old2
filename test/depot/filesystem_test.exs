defmodule Depot.TestFilesystem do
  use Depot.Filesystem, otp_app: :depot
end

defmodule Depot.FilesystemTest do
  use ExUnit.Case, async: false

  alias Depot.TestFilesystem, as: Filesystem

  setup do
    {:ok, _pid} = start_supervised(Filesystem)
    :ok
  end

  test "write file" do
    assert :ok = Filesystem.write("test.txt", "hello")
  end

  test "read file" do
    Filesystem.write("test.txt", "hello")
    assert {:ok, "hello"} = Filesystem.read("test.txt")
  end
end
