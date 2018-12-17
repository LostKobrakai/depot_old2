defmodule Depot.UtilTest do
  use ExUnit.Case, async: false

  alias Depot.Util

  describe "normalize_path/1" do
    test "success" do
      assert "test.txt" == Util.normalize_path("test.txt")
      assert "test.txt" == Util.normalize_path("/test.txt")
      assert "test.txt" == Util.normalize_path("./test.txt")
      assert "test.txt" == Util.normalize_path("/./test.txt")
      assert "test.txt" == Util.normalize_path("/folder/../test.txt")
    end

    test "prevent tries to get outside of root" do
      refute Util.normalize_path("../test.txt") |> relative_path_starts_with_folder_up()
      refute Util.normalize_path("/../test.txt") |> relative_path_starts_with_folder_up()
      refute Util.normalize_path("test/../../test.txt") |> relative_path_starts_with_folder_up()
      refute Util.normalize_path("/test/../../test.txt") |> relative_path_starts_with_folder_up()

      refute Util.normalize_path("test/../../../test.txt")
             |> relative_path_starts_with_folder_up()

      refute Util.normalize_path("/test/../../../test.txt")
             |> relative_path_starts_with_folder_up()
    end
  end

  defp relative_path_starts_with_folder_up(path) do
    ".." == path |> Path.split() |> List.first()
  end
end
