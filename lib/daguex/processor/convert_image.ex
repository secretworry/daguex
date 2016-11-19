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

  def init([variants: variants]) do
    for variant <- variants, into: %{} do
      {variant.format, variant}
    end
  end

  def init(_), do: raise ArgumentError, "variants is required for #{__MODULE__}"

  def process(context, variants) do
    formats = get_formats(context.opts, variants)
    with {:ok, formats} <- validate_formats(formats, variants),
     do: convert_images(context, formats, variants)
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

  defp convert_images(context, formats, variants) do
  end

end