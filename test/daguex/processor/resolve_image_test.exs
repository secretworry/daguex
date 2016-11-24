defmodule Daguex.Processor.ResolveImageTest do

  use Daguex.DaguexCase

  alias Daguex.Processor.ResolveImage
  alias Daguex.ImageFile
  alias Daguex.Pipeline.Context
  import Daguex.ContextHelper
  import Daguex.Processor.StorageHelper

  describe "init/1" do
    test "should raise error for not passing in storages" do
      assert_raise ArgumentError, "storages is required for Daguex.Processor.ResolveImage", fn->
        ResolveImage.init([])
      end
    end
  end

  @image "test/support/daguex.png"

  describe "process/2" do
    test "should resolve image to target url" do
      storage_name = "name"
      processor_opts = ResolveImage.init(storages: [{storage_name, TestStorage, []}])
      context = create_context(@image, "image") |> Context.put_opts(:format, "format")
      image_file = ImageFile.from_file!(@image)
      {:ok, context} = put_local_image(context, image_file, "format")
      {:ok, image} = put_image(context.image, image_file, nil, "key", "format", storage_name, {TestStorage, []})
      context = %{context | image: image}
      {:ok, context} = ResolveImage.process(context, processor_opts)
      expect_uri = ("file://" <> (@image |> Path.expand(File.cwd!))) |> URI.parse
      assert expect_uri == ResolveImage.get_result(context).uri
    end
  end
end
