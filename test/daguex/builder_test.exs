defmodule Daguex.BuilderTest do
  use Daguex.DaguexCase

  defmodule TestDaguex do
    use Daguex.Builder
    repo TestRepo
    local_storage TestStorage, local: true
    storage TestStorage, key: 1
    storage TestStorage, key: 2
    variant :format_1, :convert, key: 1
    variant :format_2, :convert, key: 2
    def convert(image, _opts), do: {:ok, image}
  end

  test "export __daguex__ functions" do
    assert TestDaguex.__daguex__(:repo) == TestRepo
    assert TestDaguex.__daguex__(:storages) == [{TestStorage, [key: 1]}, {TestStorage, [key: 2]}]
    assert TestDaguex.__daguex__(:variants) == [%Daguex.Variant{format: :format_1, converter: :convert, opts: [key: 1]}, %Daguex.Variant{format: :format_2, converter: :convert, opts: [key: 2]}]
    assert TestDaguex.__daguex__(:local_storage) == {TestStorage, [local: true]}
  end

  test "raise erro for undefined variant converter method" do
    assert_raise Daguex.Error, fn ->
      defmodule UndefinedConverterDaguex do
        use Daguex.Builder
        repo TestRepo
        variant :norma, :undefined
      end
    end
  end

  test "raise error for not defining repo" do
    assert_raise Daguex.Error, ~r/^repo is required for .*, but not specified/, fn->
      defmodule MissingRepoDaguex do
        use Daguex.Builder
        local_storage TestStorage
      end
    end
  end

  test "raise error for not defining local_storage" do
    assert_raise Daguex.Error, ~r/^local_storage is required for .*, but not specified/, fn->
      defmodule MissingLocalStorageDaguex do
        use Daguex.Builder
        repo TestRepo
      end
    end
  end

end