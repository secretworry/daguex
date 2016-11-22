defmodule Daguex.LocalStorageTest do
  use Daguex.DaguexCase

  alias Daguex.LocalStorage

  @image "test/support/daguex.png"

  @base_path "/tmp/daguex/image"

  setup_all do
    File.mkdir_p(@base_path)
    on_exit(fn ->
      File.rm_rf(@base_path)
    end)
  end

  describe "init/1" do
    test "should raise error for not passing in base_path" do
      assert_raise ArgumentError, "base_path is required for `Daguex.LocalStorage`", fn ->
        LocalStorage.init([])
      end
    end

    test "should normalize the given base_path" do
      path = "."
      [base_path: base_path] = LocalStorage.init([base_path: path])
      assert base_path == Path.expand(path, File.cwd!) <> "/"
    end
  end

  describe "put/3" do
    test "should put the image to the specified directory" do
      options = LocalStorage.init([base_path: @base_path])
      key = "daguex.png"
      {:ok, key} = LocalStorage.put(@image, key, "test", options)
      {:ok, _} = LocalStorage.get(key, options)
    end
  end

  describe "resolve/2" do
    test "should resolve to a local file if no assets_url is given" do
      options = LocalStorage.init([base_path: @base_path])
      key = "daguex.png"
      {:ok, key} = LocalStorage.put(@image, key, "test", options)
      {:ok, url} = LocalStorage.resolve(key, options)
      "file://" <> _ = url
    end

    test "should resolve image according to given assets_url" do
      assets_url = "http://example.com/images/"
      options = LocalStorage.init([base_path: @base_path, assets_url: assets_url])
      key = "daguex.png"
      {:ok, key} = LocalStorage.put(@image, key, "test", options)
      {:ok, url} = LocalStorage.resolve(key, options)
      assert String.starts_with?(url, assets_url)
    end
  end

  describe "rm/2" do
    test "should remove a saved image" do
      options = LocalStorage.init([base_path: @base_path])
      key = "daguex.png"
      {:ok, key} = LocalStorage.put(@image, key, "test", options)
      :ok = LocalStorage.rm(key, options)
      assert {:error, :not_found} == LocalStorage.get(key, options)
    end
  end
end
