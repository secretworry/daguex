defmodule Daguex.Processor.PersistImageTest do

  use Daguex.DaguexCase

  alias __MODULE__
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
      {:ok, _} = Pipeline.call(context, [{PersistImage, [repo: TestRepo]}])
      {:ok, _} = TestRepo.load("test", [])
    end

    test "should persist a stale image" do
      defmodule StaleRepo do
        @behaviour Daguex.Repo
        def dump(image, updater, opts \\ []) do
          {:ok, updater.(image)}
        end

        def load(image, opts \\[]) do
        end
      end

      context = create_context(@image, "test")
      {:ok, _} = Pipeline.call(context, [{PersistImage, [repo: PersistImageTest.StaleRepo]}])
    end
  end
end