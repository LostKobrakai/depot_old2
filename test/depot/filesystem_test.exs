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

  test "update file" do
    Filesystem.write("test.txt", "hello")
    Filesystem.update("test.txt", "updated")
    assert {:ok, "updated"} = Filesystem.read("test.txt")
  end

  test "delete file" do
    Filesystem.write("test.txt", "hello")
    Filesystem.delete("test.txt")
    assert {:error, _} = Filesystem.read("test.txt")
  end

  test "copy file" do
    Filesystem.write("test.txt", "hello")
    Filesystem.copy("test.txt", "test_2.txt")
    assert {:ok, "hello"} = Filesystem.read("test_2.txt")
  end

  test "has file" do
    Filesystem.write("test.txt", "hello")
    assert Filesystem.has?("test.txt")
    refute Filesystem.has?("test_2.txt")
  end
end
