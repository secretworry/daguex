defmodule Daguex.Processor.StorageHelper do
  @moduledoc """
  Helpers for using `Daguex.Processor` in the `Daguex.Processor`
  """

  alias Daguex.{Image, ImageFile}

  def put_image(context, image_file, id, format, storage_name, {storage, opts}) do
    id = Path.join([format, ImageFile.default_filename(id, image_file)])
    image = context.image
    case storage.put(image_file.path, id, Keyword.get(context.opts, :bucket), opts) do
      {:ok, identifier} ->
        {:ok, update_variant(image, format, identifier, image_file)}
      {:ok, identifier, extra} ->
        image = image |> update_variant(format, identifier, image_file) |> update_extra(storage_name, format, extra)
        {:ok, image}
      error -> error
    end
  end

  def get_image(image, format, storage_name, {storage, opts}) do
    prepare_params(image, format, storage_name, fn variant, extra ->
      storage.get(variant["id"], extra, opts)
    end)
  end

  def resolve_image(image, format, storage_name, {storage, opts}) do
    prepare_params(image, format, storage_name, fn variant, extra ->
      storage.resolve(variant["id"], extra, opts)
    end)
  end

  defp prepare_params(image, format, storage_name, callback) do
    case Image.get_variant(image, format) do
      nil -> {:error, :not_found}
      variant ->
        extra = get_extra(image, storage_name, format)
        callback.(variant, extra)
    end
  end

  defp get_extra(image, storage_name, format) do
    get_in image, ["extras", storage_name, format]
  end

  defp update_variant(image, format, id, image_file) do
    Image.add_variant(image, format, id, image_file.width, image_file.height, image_file.type)
  end

  defp update_extra(image, storage_name, format, payload) do
    Image.put_data(image, ["extras", storage_name, format], payload)
  end

end