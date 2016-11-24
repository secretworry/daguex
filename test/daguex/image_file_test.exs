defmodule Daguex.ImageFileTest do

  use ExUnit.Case

  alias Daguex.ImageFile

  @path "test/support/daguex.png"

  describe "from_file/3" do
    test "should create ImageFile from a path" do
      {:ok, image_file} = ImageFile.from_file(@path)
      uri = @path |> Path.expand(File.cwd!) |> URI.parse
      assert %Daguex.ImageFile{height: 200, uri: uri,
               type: "png", width: 200} == image_file
    end
  end
end