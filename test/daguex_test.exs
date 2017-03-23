defmodule DaguexTest do
  use Daguex.DaguexCase

  alias Daguex.ImageFile

  setup do
    {:ok, pid} = TestStorage.start_link
    [local_storage_pid: pid]
  end

  defmodule TestDaguex do
    use Daguex.Builder
    local_storage TestStorage
    repo TestRepo
    variant "s100", Daguex.Variant.DefaultConverter, size: "100x100"
  end

  @image "test/support/daguex.png"

  describe "put/3" do
    test "should work without error", context do
      pid = Map.get(context, :local_storage_pid)

      defmodule PutDaguex do
        use Daguex.Builder
        local_storage TestStorage
        repo TestRepo
        storage "test", TestStorage, [pid: pid]
        variant "s100", Daguex.Variant.DefaultConverter, size: "100x100"
      end

      {:ok, image_file} = ImageFile.from_file(@image)
      assert {:ok, "key"} == PutDaguex.put(image_file, "key", bucket: "bucket")
      {:ok, %{key: key, width: width, height: height, variants: variants} = image} = TestRepo.load("key")
      assert ["key", image_file.width, image_file.height] == [key, width, height]
      assert ["orig", "s100"] == Map.keys(variants)

      storage_opts = TestStorage.init(pid: pid)
      {:ok, _} = Daguex.Processor.StorageHelper.get_image(image, "orig", "test", {TestStorage, storage_opts})
      {:ok, _} = Daguex.Processor.StorageHelper.get_image(image, "s100", "test", {TestStorage, storage_opts})
    end

    test "should reject putting a non-local image_file" do
      image_file = ImageFile.build("http://example.com/images/test.png", "png", 100, 100)
      assert {:error, "Cannot put a non-local ImageFile"} == TestDaguex.put(image_file, "key", [])
    end
  end

  describe "resolve/3" do

    test "should resovle without error", context do
      pid = Map.get(context, :local_storage_pid)
      defmodule ResolveDaguex do
        use Daguex.Builder
        local_storage TestStorage
        repo TestRepo
        storage "test", TestStorage, [pid: pid]
        variant "s100", Daguex.Variant.DefaultConverter, size: "100x100"
      end
      {:ok, image_file} = ImageFile.from_file(@image)
      {:ok, key} = ResolveDaguex.put(image_file, "key", bucket: "bucket")
      {:ok, _url} = ResolveDaguex.resolve(key, "s100", [])
    end

    test "should resolve an image without converting specified format", context do
      pid = Map.get(context, :local_storage_pid)
      defmodule ResolveDaguex do
        use Daguex.Builder
        local_storage TestStorage
        repo TestRepo
        storage "test", TestStorage, [pid: pid]
        variant "s100", Daguex.Variant.DefaultConverter, size: "100x100"
      end
      defmodule UpdatedDaguex do
        use Daguex.Builder
        local_storage TestStorage
        repo TestRepo
        storage "test", TestStorage, [pid: pid]
        variant "s100", Daguex.Variant.DefaultConverter, size: "100x100"
        variant "s200", Daguex.Variant.DefaultConverter, size: "200x200"
      end

      {:ok, image_file} = ImageFile.from_file(@image)
      {:ok, key} = ResolveDaguex.put(image_file, "key", bucket: "bucket")
      {:ok, image} = UpdatedDaguex.resolve(key, "s200", [])
      assert File.exists?(image.uri.path)
    end
  end

  describe "get/3" do

    test "should get an image without erro", context do
      pid = Map.get(context, :local_storage_pid)
      defmodule GetDaguex do
        use Daguex.Builder
        local_storage TestStorage
        repo TestRepo
        storage "test", TestStorage, [pid: pid]
        variant "s100", Daguex.Variant.DefaultConverter, size: "100x100"
      end
      {:ok, image_file} = ImageFile.from_file(@image)
      {:ok, key} = GetDaguex.put(image_file, "key", bucket: "bucket")
      {:ok, _path} = GetDaguex.get(key, "s100", [])

    end

    test "should get an image without converting specified format", context do
      pid = Map.get(context, :local_storage_pid)
      defmodule GetDaguex do
        use Daguex.Builder
        local_storage TestStorage
        repo TestRepo
        storage "test", TestStorage, [pid: pid]
        variant "s100", Daguex.Variant.DefaultConverter, size: "100x100"
      end
      
      defmodule UpdatedDaguex do
        use Daguex.Builder
        local_storage TestStorage
        repo TestRepo
        storage "test", TestStorage, [pid: pid]
        variant "s100", Daguex.Variant.DefaultConverter, size: "100x100"
        variant "s200", Daguex.Variant.DefaultConverter, size: "200x200"
      end

      {:ok, image_file} = ImageFile.from_file(@image)
      {:ok, key} = GetDaguex.put(image_file, "key", bucket: "bucket")
      {:ok, image} = UpdatedDaguex.get(key, "s200", [])
      assert File.exists?(image.uri.path)
    end
  end
end
