defmodule Daguex.Builder do
  defmacro __using__(_opts) do
    quote do
      import Daguex.Builder.Variant
      import Daguex.Builder.Storage
      import Daguex.Builder.Repo
      @before_compile Daguex.Builder

      Module.register_attribute __MODULE__,
        :variants, accumulate: true, persist: false
      Module.register_attribute __MODULE__,
        :storages, accumulate: true, persist: false
      Module.register_attribute __MODULE__,
        :repo, accumulate: false, persist: false

      def put(image_file, opts) do
        builder_put_call(image_file, opts)
      end

      def get(identifier, format, opts) do
        builder_get_call(identifier, format, opts)
      end

      def resolve(identifier, format, opts) do
        builder_resolve_call(identifier, format, opts)
      end
    end
  end

  defmacro __before_compile__(env) do
    module = env.module
    variants = Module.get_attribute(module, :variants) |> Enum.reverse |> Daguex.Builder.validate_variants(module) |> Macro.escape
    storages = Module.get_attribute(module, :storages) |> Enum.reverse |> Macro.escape
    repo = Module.get_attribute(module, :repo) |> Macro.escape

    quote do
      def __daguex__(:variants), do: unquote(variants)
      def __daguex__(:storages), do: unquote(storages)
      def __daguex__(:repo), do: unquote(repo)


      def builder_put_call(image_file, opts) do
      end

      def builder_get_call(identifier, format, opts) do
      end

      def builder_resolve_call(identifier, format, opts) do
      end
    end
  end

  def validate_variants(variants, module) do
    Enum.each(variants, fn %{converter: converter} ->
      case Atom.to_char_list(converter) do
        ~c"Elixir." ++ _ -> :ok
        _ ->
          if Module.defines?(module, {converter, 2}, :def), do: :ok, else: raise Daguex.Error, "#{module} should implement #{converter}/2"
      end
    end)
    variants
  end
end
