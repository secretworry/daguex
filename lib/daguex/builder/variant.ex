defmodule Daguex.Builder.Variant do

  defmacro variant(format, converter, opts \\ []) do
    converter = preprocess(converter, __CALLER__)
    quote do
      @variants %Daguex.Variant{
        format: unquote(format),
        converter: unquote(converter),
        opts: Daguex.Builder.Variant.init_opts(unquote(converter), unquote(opts))
      }
    end
  end

  def preprocess(converter, env) when is_atom(converter), do: {env.module, converter}
  def preprocess(converter, env), do: Macro.expand(converter, env)

  def init_opts({_module, _func}, opts), do: opts

  def init_opts(converter, opts), do: converter.init(opts)

end
