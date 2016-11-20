defmodule Daguex.Processor.ConvertImage do
  @moduledoc """
  Processor that convert given image to targeting format

  This processor in the charge of converting image to specified format
  and save the results to the `variants` field of `Daguex.Image`
  Convert `Context.image_file` to the format specified in the opts for `#{__MODULE__}.process/2`
  or all the format that defined through opts for this module, if not format is given.
  Save the result of converting to
  """

  use Daguex.Processor

  alias Daguex.{LocalImage, Variant}
  import Daguex.Processor.StorageHelper

  def init(opts) do
    variants = case Keyword.fetch(opts, :variants) do
      {:ok, variants} -> variants
      :error -> raise ArgumentError, "variants is required for #{inspect __MODULE__}"
    end
    local_storage = case Keyword.fetch(opts, :local_storage) do
      {:ok, local_storage} -> local_storage
      :error -> raise ArgumentError, "local_storage is required for #{inspect __MODULE__}"
    end
    variants = for variant <- variants, into: %{} do
      {variant.format, variant}
    end
    %{variants: variants, local_storage: local_storage}
  end

  def process(context, %{variants: variants, local_storage: local_storage}) do
    formats = get_formats(context.opts, variants)
    with {:ok, formats} <- validate_formats(formats, variants),
     do: convert_images(context, formats, variants, local_storage)
  end

  defp get_formats(opts, variants) do
    formats = Keyword.get(opts, :format) || Keyword.get(opts, :formats) || Map.keys(variants)
    List.wrap(formats)
  end

  defp validate_formats(formats, variants) do
    Enum.reduce_while(formats, nil, fn
      format, nil -> if Map.has_key?(variants, format), do: {:cont, nil}, else: {:halt, {:error, "Illegal format '#{format}'"}}
    end) || {:ok, formats}
  end

  defp convert_images(context, formats, variants, local_storage) do
    Enum.reduce(formats, context, fn format, context ->
      id = "#{context.image.id}_#{format}"
      with {:ok, new_image} <- convert_image(context.image_file, Map.get(variants, format)),
           {:ok, context} <- save_image(context, new_image, id, format, local_storage),
       do: context
    end)
  end

  defp convert_image(image_file, variant) do
    Variant.call(image_file, variant)
  end

  defp save_image(context, image_file, id, format, local_storage) do
    put_image_and_update_context(context, image_file, id, format, "local", local_storage)
  end

end