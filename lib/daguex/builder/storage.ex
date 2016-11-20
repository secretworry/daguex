defmodule Daguex.Builder.Storage do

  defmacro storage(name, storage, opts \\ []) do
    storage = Macro.expand(storage, __CALLER__)
    quote do
      @storages {unquote(name), unquote(storage), unquote(storage).init(unquote(opts))}
    end
  end

  defmacro local_storage(storage, opts \\ []) do
    quote do
      @local_storage {unquote(storage), unquote(storage).init(unquote(opts))}
    end
  end
end
