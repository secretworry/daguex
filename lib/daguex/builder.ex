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
    variants = Module.get_attribute(module, :variants) |> Enum.reverse |> Daguex.Builder.validate_variants()
    storages = Module.get_attribute(module, :storages) |> Enum.reverse
    repo = Module.get_attribute(module, :repo) |> Daguex.Builder.required(:repo, module)
    local_storage = Module.get_attribute(module, :local_storage) |> Daguex.Builder.required(:local_storage, module)|> Macro.escape
    process_pipeline = [
      {Daguex.Processor.ConvertImage, [variants: variants]}
    ]
    process_pipeline = Enum.reduce(storages, process_pipeline, fn {name, storage, opts}, acc ->
      [{Daguex.Processor.PutImage, [storage: {storage, opts}, name: name]} | acc]
    end) |> Enum.reverse |> Macro.escape

    persist_pipeline = [{Daguex.Processor.PersistImage, [repo: repo]}] |> Macro.escape
    get_pipeline = [] |> Macro.escape
    resolve_pipeline = [{Daguex.Processor.ResolveImage, [storages: storages]}] |> Macro.escape
    quote do
      def __daguex__(:variants), do: unquote(variants |> Macro.escape)
      def __daguex__(:storages), do: unquote(storages |> Macro.escape)
      def __daguex__(:repo), do: unquote(repo |> Macro.escape)
      def __daguex__(:local_storage), do: unquote(local_storage)


      def builder_put_call(image_file, id, opts) do
        image = Daguex.Image.from_image_file(image_file, id)
        context = %Daguex.Pipeline.Context{image: image, local_storage: unquote(local_storage), opts: opts}
        with {:ok, context} <- Daguex.Processor.StorageHelper.put_local_image(context, image_file, "orig"),
             {:ok, context} <- Daguex.Pipeline.call(context, unquote(process_pipeline)),
             {:ok, context} <- Daguex.Pipeline.call(context, unquote(persist_pipeline)) do
          {:ok, context.image.id}
        end
      end

      def builder_get_call(identifier, format, opts) do
        with {:ok, image} <- unquote(repo).load(identifier, opts),
             context = %Daguex.Pipeline.Context{image: image, local_storage: unquote(local_storage), opts: opts |> Keyword.put(:format, format)},
             {:ok, context} <- Daguex.pipeline.call(context, unquote(resolve_pipeline)) do
          :ok
        end
      end

      def builder_resolve_call(identifier, format, opts) do
        with {:ok, image} <- unquote(repo).load(identifier, opts),
             context = %Daguex.Pipeline.Context{image: image, local_storage: unquote(local_storage), opts: opts |> Keyword.put(format: format)},
             {:ok, context} <- Daguex.pipeline.call(context, unquote(resolve_pipeline)) do
          {:ok, Daguex.Processor.ResolveImage.get_url(context)}
        end
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
