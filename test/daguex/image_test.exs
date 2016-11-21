defmodule Daguex.ImageTest do
  use ExUnit.Case

  alias Daguex.Image

  @default_image %Image{id: "id", width: 100, height: 100, type: "png"}

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

  describe "add_variant/6" do
    test "should add given variant to image" do
      image = Image.add_variant(@default_image, "test", "test", 100, 100, "png")
      expected_variant = %{"height" => 100, "id" => "test", "type" => "png", "width" => 100}
      assert expected_variant == image |> Image.get_variant("test")
    end
  end

  describe "has_viarant/2" do
    test "should return false for non-exsiting variant" do
      refute Image.has_variant?(@default_image, "not_exist")
    end

    test "should return true for a persisted variant" do
      image = %{@default_image | variants: %{"test" => %{"height" => 100, "id" => "test", "type" => "png", "width" => 100}}}
      assert Image.has_variant?(image, "test")
    end

    test "should return true for a new variant" do
      image = @default_image |> Image.add_variant("test", "test", 100, 100, "png")
      assert Image.has_variant?(image, "test")
    end
  end

  describe "rm_variant/2" do
    test "should remove a non-exsiting variant without error" do
      image = @default_image |> Image.rm_variant("test")
      refute Image.has_variant?(image, "test")
    end

    test "should remove a persisted variant" do
      image = %{@default_image | variants: %{"test" => %{"height" => 100, "id" => "test", "type" => "png", "width" => 100}}}
      image = image |> Image.rm_variant("test")
      refute Image.has_variant?(image, "test")
    end

    test "should remove a new variant" do
      image = @default_image |> Image.add_variant("test", "test", 100, 100, "png")
      image = image |> Image.rm_variant("test")
      refute Image.has_variant?(image, "test")
    end
  end

  describe "apply_variants_mod" do
    test "should apply an adding modification" do
      image = @default_image |> Image.add_variant("test", "test", 100, 100, "png")
      image = image |> Image.apply_variants_mod()
      expect = %{"test" => %{"height" => 100, "id" => "test", "type" => "png", "width" => 100}}
      assert expect == image.variants
    end

    test "should apply a removing modification" do
      image = %{@default_image | variants: %{"test" => %{"height" => 100, "id" => "test", "type" => "png", "width" => 100}}}
      image = image |> Image.rm_variant("test") |> Image.apply_variants_mod()
      assert %{} == image.variants
    end
  end
end