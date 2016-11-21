defmodule Daguex.Processor.PersistImageTest do

  use Daguex.DaguexCase

  alias Daguex.Processor.PersistImage
  alias Daguex.Pipeline
  import Daguex.ContextHelper

  describe "init/1" do
    test "should raise error for not passing in repo" do
      assert_raise ArgumentError, "repo is required for Daguex.Processor.PersistImage", fn->
        PersistImage.init([])
      end
    end
  end

  @image "test/support/daguex.png"

  describe "process/1" do
    test "should persist image to given repo" do
      context = create_context(@image, "test")
      {:ok, context} = Pipeline.call(context, [{PersistImage, [repo: TestRepo]}])
      {:ok, _} = TestRepo.load("test", [])
    end
  end
end