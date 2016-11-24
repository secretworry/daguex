defmodule Daguex.Processor.StorageHelper do
  @moduledoc """
  Helpers for using `Daguex.Processor` in the `Daguex.Processor`
  """

  alias Daguex.{Image, ImageFile, ImageHelper}

  def put_local_image(context, image_file, format) do
    key = ImageHelper.variant_key(image_file, context.image.key, format)
    bucket = Keyword.get(context.opts, :bucket)
    {local_storage, opts} = context.local_storage
    with {:ok, image} <- put_image(context.image, image_file, bucket, key, format, "local", context.local_storage),
         store_key     <- get_key(image, "local", format),
         image        <- update_variant(image, format, key, image_file),
         {:ok, path}  <- local_storage.get(store_key, opts),
         {:ok, image_file} <- ImageFile.from_file(path) do
      context = %{context | image: image} |> cache_local_image(format, image_file)
      {:ok, context}
    end
  end

  def load_local_image(context, format) do
    case get_cached_local_image(context, format) do
      nil ->
        {local_storage, opts} = context.local_storage
        case Image.get_variant(context.image, format) do
          nil -> {:error, :not_found}
          %{"key" => key} ->
            with {:ok, path} <- local_storage.get(key, opts),
                 {:ok, image_file} <- ImageFile.from_file(path) do
              context = context |> cache_local_image(format, image_file)
              {:ok, context, image_file}
            end
        end
      local_image -> {:ok, context, local_image}
    end
  end

  defp cache_local_image(context, format, image_file) do
    update_in context.private, fn private ->
      Map.update(private, :local_images, %{format => image_file}, &Map.put(&1, format, image_file))
    end
  end

  defp get_cached_local_image(context, format) do
    get_in context.private, [:local_images, format]
  end

  def put_image(image, image_file, bucket, key, format, storage_name, {storage, opts}) do
    case storage.put(image_file.uri |> to_string, key, bucket, opts) do
      {:ok, key} ->
        {:ok, update_key(image, storage_name, format, key)}
      {:ok, key, extra} ->
        image = image |> update_key(storage_name, format, key) |> update_extra(storage_name, format, extra)
        {:ok, image}
      error -> error
    end
  end

  def get_image(image, format, storage_name, {storage, opts}) do
    prepare_params(image, format, storage_name, fn key, extra ->
      storage.get(key, extra, opts)
    end)
  end

  def resolve_image(image, format, storage_name, {storage, opts}) do
    prepare_params(image, format, storage_name, fn key, extra ->
      storage.resolve(key, extra, opts)
    end)
  end

  def saved?(image, storage_name, format) do
    get_key(image, storage_name, format)
  end

  defp prepare_params(image, format, storage_name, callback) do
    case Image.get_variant(image, format) do
      nil -> {:error, :not_found}
      _ ->
        key = get_key(image, storage_name, format)
        extra = get_extra(image, storage_name, format)
        callback.(key, extra)
    end
  end

  def get_extra(image, storage_name, format) do
    Image.get_data(image, ["extras", storage_name, format])
  end

  def get_key(image, storage_name, format) do
    Image.get_data(image, ["ids", storage_name, format])
  end

  def update_key(image, storage_name, format, key) do
    Image.put_data(image, ["ids", storage_name, format], key)
  end

  def update_variant(image, format, key, image_file) do
    Image.add_variant(image, format, key, image_file.width, image_file.height, image_file.type)
  end

  def update_extra(image, storage_name, format, extra) do
    Image.put_data(image, ["extras", storage_name, format], extra)
  end

end
