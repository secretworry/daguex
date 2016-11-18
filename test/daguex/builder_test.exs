defmodule Daguex.BuilderTest do
  use ExUnit.Case

  defmodule TestDaguex do
    use Daguex.Builder
    repo DummyRepo
    storage DummyStorage, key: 1
    storage DummyStorage, key: 2
    variant :format_1, :convert, key: 1
    variant :format_2, :convert, key: 2
    def convert(image, _opts), do: {:ok, image}
  end

  test "export __daguex__ functions" do
    assert TestDaguex.__daguex__(:repo) == DummyRepo
    assert TestDaguex.__daguex__(:storages) == [{DummyStorage, [key: 1]}, {DummyStorage, [key: 2]}]
    assert TestDaguex.__daguex__(:variants) == [%Daguex.Variant{format: :format_1, converter: :convert, opts: [key: 1]}, %Daguex.Variant{format: :format_2, converter: :convert, opts: [key: 2]}]
  end

  test "raise erro for undefined variant converter method" do
    assert_raise Daguex.Error, fn ->
      defmodule UndefinedConverterDaguex do
        use Daguex.Builder
        repo DummyRepo
        variant :norma, :undefined
      end
    end
  end
end