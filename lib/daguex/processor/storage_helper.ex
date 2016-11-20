defmodule Daguex.Processor.StorageHelper do
  @moduledoc """
  Helpers for using `Daguex.Processor` in the `Daguex.Processor`
  """

  alias Daguex.{Image, ImageFile}

  def put_local_image(image, image_file, bucket, id, format, {storage, opts}) do
    id = Path.join([format, ImageFile.default_filename(id, image_file)])
    with {:ok, image} <- put_image(image, image_file, bucket, id, format, "local", {storage, opts}) do
      {:ok, image |> update_variant(format, id, image_file)}
    end
  end

  def put_image(image, image_file, bucket, id, format, storage_name, {storage, opts}) do
    case storage.put(image_file.path, id, bucket, opts) do
      {:ok, identifier} ->
        {:ok, update_id(image, storage_name, format, identifier)}
      {:ok, identifier, extra} ->
        image = image |> update_id(storage_name, format, identifier) |> update_extra(storage_name, format, extra)
        {:ok, image}
      error -> error
    end
  end

  def get_image(image, format, storage_name, {storage, opts}) do
    prepare_params(image, format, storage_name, fn id, extra ->
      storage.get(id, extra, opts)
    end)
  end

  def resolve_image(image, format, storage_name, {storage, opts}) do
    prepare_params(image, format, storage_name, fn id, extra ->
      storage.resolve(id, extra, opts)
    end)
  end

  defp prepare_params(image, format, storage_name, callback) do
    case Image.get_variant(image, format) do
      nil -> {:error, :not_found}
      variant ->
        id = get_id(image, storage_name, format)
        extra = get_extra(image, storage_name, format)
        callback.(id, extra)
    end
  end

  defp get_extra(image, storage_name, format) do
    get_in image, ["extras", storage_name, format]
  end

  defp get_id(image, storage_name, format) do
    get_in image, ["ids", storage_name, format]
  end

  defp update_id(image, storage_name, format, id) do
    Image.put_data(image, ["ids", storage_name, format], id)
  end

  defp update_variant(image, format, id, image_file) do
    Image.add_variant(image, format, id, image_file.width, image_file.height, image_file.type)
  end

  defp update_extra(image, storage_name, format, extra) do
    Image.put_data(image, ["extras", storage_name, format], extra)
  end

end