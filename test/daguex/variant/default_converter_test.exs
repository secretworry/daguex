defmodule Daguex.Variant.DefaultConverterTest do

  use ExUnit.Case

  alias Daguex.ImageFile
  alias Daguex.Variant.DefaultConverter

  @image "test/support/daguex.png"

  describe "init/1" do

    test "should raise error for not passing the size option" do
      assert_raise ArgumentError, fn ->
        DefaultConverter.init([])
      end
    end

    test "should return the opts passed in" do
      options = [size: "400x400"]
      assert DefaultConverter.init(options) == options
    end
  end

  describe "convert/2" do
    test "should convert a image and save it to a temporay file" do
      options = [size: "100x100"]
      image_file = ImageFile.from_file!(@image)
      {:ok, image} = DefaultConverter.convert(image_file, options)
      assert [100, 100] == [image.width, image.height]
    end
  end
end