defmodule Daguex.BuilderTest do
  use Daguex.DaguexCase

  defmodule DummyStorage do
    @behaviour Dageux.Storage
    def init(opts) do
      opts
    end

    def put(_path, key, _bucket \\ nil, _opts), do: {:ok, key}

    def get(_key, _extra \\ nil, _opts), do: {:error, :not_found}

    def resolve(_key, _extra \\ nil, _opts), do: {:error, :not_found}

    def rm(_key, _extra \\ nil, _opts), do: {:error, :not_found}
  end

  defmodule TestDaguex do
    use Daguex.Builder
    repo TestRepo
    local_storage DummyStorage, local: true
    storage "test_1", DummyStorage, key: 1
    storage "test_2", DummyStorage, key: 2
    variant :format_1, :convert, key: 1
    variant :format_2, :convert, key: 2
    def convert(image, _opts), do: {:ok, image}
  end

  test "export __daguex__ functions" do
    assert TestDaguex.__daguex__(:repo) == TestRepo
    assert TestDaguex.__daguex__(:storages) == [{"test_1", DummyStorage, [key: 1]}, {"test_2", DummyStorage, [key: 2]}]
    assert TestDaguex.__daguex__(:variants) == [%Daguex.Variant{format: :format_1, converter: {Daguex.BuilderTest.TestDaguex, :convert}, opts: [key: 1]}, %Daguex.Variant{format: :format_2, converter: {Daguex.BuilderTest.TestDaguex, :convert}, opts: [key: 2]}]
    assert TestDaguex.__daguex__(:local_storage) == {DummyStorage, [local: true]}
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
