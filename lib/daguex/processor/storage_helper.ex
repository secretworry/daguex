defmodule Daguex.Processor.StorageHelper do
  @moduledoc """
  Helpers for using `Daguex.Processor` in the `Daguex.Processor`
  """

  alias Daguex.{Image, ImageFile}

  def put_image_and_update_context(context, image_file, id, format, storage_name, {storage, opts}) do
    id = Path.join([format, ImageFile.default_filename(id, image_file)])
    context_or_error = case storage.put(image_file.path, id, Keyword.get(context.opts, :bucket), opts) do
      {:ok, identifier} -> update_variant(context, format, identifier, image_file)
      {:ok, identifier, payload} ->
        context |> update_variant(format, identifier, image_file) |> update_payload(storage_name, format, payload)
      error -> error
    end
    case context_or_error do
      {:error, _} = error -> error
      context -> {:ok, context}
    end
  end

  defp update_variant(context, format, id, image_file) do
    update_in context.image, &Image.add_variant(&1, format, id, image_file.width, image_file.height, image_file.type)
  end

  defp update_payload(context, storage_name, format, payload) do
    update_in context.image, &Image.put_data(&1, ["payloads", storage_name, format], payload)
  end
end