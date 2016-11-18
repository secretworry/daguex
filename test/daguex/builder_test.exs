defmodule Daguex.BuilderTest do
  use ExUnit.Case

  defmodule TestDaguex do
    use Daguex.Builder
    repo DummyRepo
    storage DummyStorage, key: 1
    storage DummyStorage, key: 2
  end

  test "export __daguex__ functions" do
    assert TestDaguex.__daguex__(:repo) == DummyRepo
    assert TestDaguex.__daguex__(:storages) == [{DummyStorage, [key: 1]}, {DummyStorage, [key: 2]}]
  end
end