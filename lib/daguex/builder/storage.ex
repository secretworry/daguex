defmodule Daguex.Builder.Storage do

  defmacro storage(storage, opts \\ %{}) do
    storage = Macro.expand(storage, __CALLER__)
    quote do
      @storages {unquote(storage), unquote(storage).init(unquote(opts))}
    end
  end
end
