defmodule Daguex.Processor.LoadLocalImageTest do
  use Daguex.DaguexCase
  import Daguex.ContextHelper

  alias Daguex.Processor.LoadLocalImage

  @image "test/support/daguex.png"

  describe "init/1" do

    test "should raise error for not specifying local_storage" do
      assert_raise ArgumentError, fn ->
        LoadLocalImage.init([])
      end
    end
  end

  describe "process/2" do
    test "should load local_image into the context" do
      options = [local_storage: TestStorage]
      {:ok, context} = create_context(@image) |> LoadLocalImage.process(options)
      assert context.image_file
    end
  end
end