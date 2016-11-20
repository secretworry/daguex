defmodule Daguex.ImageFileTest do

  use ExUnit.Case

  alias Daguex.ImageFile

  @path "test/support/daguex.png"

  describe "from_file/3" do
    test "should create ImageFile from a path" do
      {:ok, image_file} = ImageFile.from_file(@path)
      assert %Daguex.ImageFile{height: 200, path: "test/support/daguex.png",
               type: "png", width: 200} == image_file
    end
  end

  describe "default_filename/1" do
    test "should generate expecting filename" do
      {:ok, image_file} = ImageFile.from_file(@path)
      filename = ImageFile.default_filename("daguex", image_file)
      assert "daguex_200_200.png" == filename
    end
  end

end