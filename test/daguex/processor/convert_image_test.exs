defmodule Daguex.Processor.ConvertImageTest do

  use Daguex.DaguexCase
  import Daguex.ContextHelper

  alias Daguex.Processor.ConvertImage
  alias Daguex.{Image, Variant}
  alias Daguex.Variant.DefaultConverter

  @image "test/support/daguex.png"

  describe "init/1" do
    test "should raise ArgumentError for not passing in variants" do
      assert_raise ArgumentError, "variants is required for Daguex.Processor.ConvertImage", fn->
        ConvertImage.init(local_storage: {TestStorage, TestStorage.init([])})
      end
    end
  end

  describe "process/2" do
    test "should convert image to all supported formats if format is not specified" do
      options = ConvertImage.init(
        local_storage: {TestStorage, TestStorage.init([])},
        variants: [%Variant{format: "s100", converter: DefaultConverter, opts: [size: "100x100"]}, %Variant{format: "s50", converter: DefaultConverter, opts: [size: "50x50"]}])
      context = create_context(@image)
      {:ok, context} = ConvertImage.process(context, options)
      expect_variants = %{"s100" => %{"height" => 100, "key" => "daguex_s100_100_100.png", "type" => "png", "width" => 100},
                          "s50" => %{"height" => 50, "key" => "daguex_s50_50_50.png", "type" => "png", "width" => 50},
                          "orig" => %{"height" => 200, "key" => "daguex_200_200.png", "type" => "png", "width" => 200}}
      variants = (context.image |> Image.apply_variants_mod).variants
      assert expect_variants == variants
      {:ok, _} = TestStorage.get(variants["s100"]["key"], [])
      {:ok, _} = TestStorage.get(variants["s50"]["key"], [])
    end

    test "should convert image to specified format" do
      options = ConvertImage.init(
        local_storage: {TestStorage, TestStorage.init([])},
        variants: [%Variant{format: "s100", converter: DefaultConverter, opts: [size: "100x100"]}, %Variant{format: "s50", converter: DefaultConverter, opts: [size: "50x50"]}])
      context = create_context(@image)
      context = put_in context.opts, [format: "s100"]
      {:ok, context} = ConvertImage.process(context, options)
      expect_variants = %{"s100" => %{"height" => 100, "key" => "daguex_s100_100_100.png", "type" => "png", "width" => 100},
                          "orig" => %{"height" => 200, "key" => "daguex_200_200.png", "type" => "png", "width" => 200}}
      variants = (context.image |> Image.apply_variants_mod).variants
      assert expect_variants == variants
      {:ok, _} = TestStorage.get(variants["s100"]["key"], [])
    end
  end
end
