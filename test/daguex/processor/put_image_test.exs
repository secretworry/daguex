defmodule Daguex.Processor.PutImageTest do
  @moduledoc false

  use Daguex.DaguexCase
  import Daguex.ContextHelper

  alias Daguex.Image
  alias Daguex.Processor.PutImage
  alias Daguex.Pipeline

  @image "test/support/daguex.png"

  setup do
    {:ok, pid} = TestStorage.start_link
    opts = TestStorage.init(pid: pid)
    [storage: {TestStorage, opts}]
  end

  describe "init/1" do
    test "should raise error for not passing in storage" do
      assert_raise ArgumentError, "storage is required for Daguex.Processor.PutImage", fn->
        PutImage.init(name: "test")
      end
    end

    test "should reaise error for not passing in name" do
      assert_raise ArgumentError, "name is required for Daguex.Processor.PutImage", fn->
        PutImage.init(storage: {TestStorage, []})
      end
    end
  end

  describe "process/2" do
    test "should put local images to specified storage", c do
      storage = Map.get(c, :storage)
      context = create_context(@image, "test")
      opts = PutImage.init(storage: storage, name: "test_storage")
      {:ok, context} = Pipeline.call(context, [{PutImage, opts}])
      image = context.image |> Image.apply_data_mod |> Image.apply_variants_mod
      data_expect = %{"ids" => %{"test_storage" => %{"orig" => "test"}}}
      assert data_expect == image.data
      assert %{} == image.variants
    end
  end
end