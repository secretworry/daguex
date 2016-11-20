defmodule Daguex.Processor.Helper do

  defmacro required_option(name) do
    quote bind_quoted: [name: name] do
      case Keyword.fetch(var!(opts), name) do
        {:ok, value} -> value
        :error -> raise ArgumentError, "#{name} is required for #{inspect __MODULE__}"
      end
    end
  end
end