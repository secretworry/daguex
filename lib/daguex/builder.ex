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
        :local_storage, accumulate: false, persist: false
      Module.register_attribute __MODULE__,
        :repo, accumulate: false, persist: false

      def put(image_file, id, opts) do
        builder_put_call(image_file, id, opts)
      end

      def get(identifier, format \\ "orig", opts) do
        builder_get_call(identifier, format, opts)
      end

      def resolve(identifier, format \\ "orig", opts) do
        builder_resolve_call(identifier, format, opts)
      end
    end
  end

  defmacro __before_compile__(env) do
    module = env.module
    variants = Module.get_attribute(module, :variants) |> Enum.reverse |> Daguex.Builder.validate_variants() |> Macro.escape
    storages = Module.get_attribute(module, :storages) |> Enum.reverse |> Macro.escape
    repo = Module.get_attribute(module, :repo) |> Daguex.Builder.required(:repo, module) |> Macro.escape
    local_storage = Module.get_attribute(module, :local_storage) |> Daguex.Builder.required(:local_storage, module)|> Macro.escape

    quote do
      def __daguex__(:variants), do: unquote(variants)
      def __daguex__(:storages), do: unquote(storages)
      def __daguex__(:repo), do: unquote(repo)
      def __daguex__(:local_storage), do: unquote(local_storage)


      def builder_put_call(image_file, id, opts) do
      end

      def builder_get_call(identifier, format, opts) do
      end

      def builder_resolve_call(identifier, format, opts) do
      end
    end
  end

  def required(value, name, module) do
    unless value do
      raise Daguex.Error, "#{name} is required for #{module}, but not specified"
    end
    value
  end

  def validate_variants(variants) do
    Enum.each(variants, fn %{converter: converter} ->
      case converter do
        module when is_atom(module) -> :ok
        {module, func} ->
          if Module.defines?(module, {func, 2}, :def), do: :ok, else: raise Daguex.Error, "#{module} should implement #{func}/2"
      end
    end)
    variants
  end
end
