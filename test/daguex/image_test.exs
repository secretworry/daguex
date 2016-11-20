defmodule Daguex.ImageTest do
  use ExUnit.Case

  alias Daguex.Image

  @default_image %Image{id: "id", width: 100, height: 100}

  describe "get_data/3" do
    test "should get nil for data not exist" do
      image = @default_image
      assert nil == Image.get_data(image, ["no_exist"])
      assert nil == Image.get_data(image, ~w{not_exist not_exist})
    end

    test "should get the data put in" do
      image = Image.put_data(@default_image, ~w{key}, "value")
      assert "value" == Image.get_data(image, ~w{key})
      image = Image.put_data(@default_image, ~w{key1}, %{"key" => "value"})
      assert %{"key" => "value"} == Image.get_data(image, ~w{key1})
    end

    test "should not get the data removed" do
      image = Image.put_data(@default_image, ~w{key}, "value")
      image = Image.rm_data(image, ~w{key})
      assert nil == Image.get_data(image, ~w{key})
    end
  end

  describe "put_data/3" do
    test "should put data in data_mod" do
      image = @default_image
      image = Image.put_data(image, ["foo", "bar"], "value")
      assert %{"foo" => %{"bar" => "value"}} == image.data_mod
    end
  end

  describe "apply_data_mod/2" do
    test "should apply data_mod" do
      image = %{@default_image | data: %{"to_remove" => "should_remove"}}
      image = image |> Image.put_data(~w{key}, "value") |> Image.rm_data(~w{to_remove}) |> Image.apply_data_mod
      assert %{"key" => "value"} == image.data
      assert %{} == image.data_mod
    end
  end
end