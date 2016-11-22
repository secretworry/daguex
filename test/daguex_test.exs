defmodule DaguexTest do
  use Daguex.DaguexCase

  alias Daguex.ImageFile

  setup do
    {:ok, pid} = TestStorage.start_link
    [local_storage_pid: pid]
  end

  @image "test/support/daguex.png"

  describe "put/3" do
    test "should work without error", context do
      pid = Map.get(context, :local_storage_pid)

      defmodule TestDaguex do
        use Daguex.Builder
        local_storage TestStorage
        repo TestRepo
        storage "test", TestStorage, [pid: pid]
        variant "s100", Daguex.Variant.DefaultConverter, size: "100x100"
      end

      {:ok, image_file} = ImageFile.from_file(@image)
      assert {:ok, "id"} == TestDaguex.put(image_file, "id", bucket: "bucket")
      {:ok, %{id: id, width: width, height: height, variants: variants} = image} = TestRepo.load("id")
      assert ["id", image_file.width, image_file.height] == [id, width, height]
      assert ["orig", "s100"] == Map.keys(variants)

      storage_opts = TestStorage.init(pid: pid)
      {:ok, _} = Daguex.Processor.StorageHelper.get_image(image, "orig", "test", {TestStorage, storage_opts})
      {:ok, _} = Daguex.Processor.StorageHelper.get_image(image, "s100", "test", {TestStorage, storage_opts})
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
      {:ok, id} = ResolveDaguex.put(image_file, "id", bucket: "bucket")
      {:ok, _url} = ResolveDaguex.resolve(id, "s100", [])
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
      {:ok, id} = GetDaguex.put(image_file, "id", bucket: "bucket")
      {:ok, _path} = GetDaguex.get(id, "s100", [])
    end
  end
end
