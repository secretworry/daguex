defmodule Daguex.Processor.PutImage do

  use Daguex.Processor
  alias Daguex.Image
  import Daguex.Processor.StorageHelper

  def init(opts) do
    %{storage: init_storage(required_option(:storage)), name: required_option(:name)}
  end

  def process(context, %{storage: storage, name: name}) do
    image = context.image
    variants = Image.variants_with_origal(image) |> filter_variants(image, name)
    with {:ok, context, variant_and_images} <- load_local_images(context, variants) do
      async(context, %{storage: storage, name: name, variants: variant_and_images}, &async_process/2, &post_process/2)
    end
  end

  def async_process(context, %{storage: {storage, opts}, name: name, variants: variants}) do
    bucket = Keyword.get(context.opts, :bucket)
    Enum.reduce_while(variants, {:ok, []}, fn {format, %{"key" => key}, image_file}, {:ok, acc} ->
      case storage.put(image_file.uri |> to_string, key, bucket, opts) do
        {:ok, identifier} -> {:cont, {:ok, [%{storage_name: name, format: format, key: identifier} | acc]}}
        {:ok, identifier, extra} -> {:cont, {:ok, [%{storage_name: name, format: format, key: identifier, extra: extra}|acc]}}
        error -> {:halt, error}
      end
    end)
  end

  def post_process(context, data) do
    Enum.reduce(data, {:ok, context}, fn
      %{storage_name: name, format: format, key: key}, {:ok, context} ->
        image = context.image |> update_key(name, format, key)
        {:ok, %{context | image: image}}
      %{storage_name: name, format: format, key: key, extra: extra}, {:ok, context} ->
        image = context.image |> update_key(name, format, key) |> update_extra(name, format, extra)
        {:ok, %{context | image: image}}
    end)
  end

  defp load_local_images(context, variants) do
    Enum.reduce_while(variants, {:ok, context, []}, fn {format, variant}, {:ok, context, acc} ->
      with {:ok, context, image_file} <- load_local_image(context, format) do
        {:cont, {:ok, context, [{format, variant, image_file}|acc]}}
      else
        e -> {:halt, e}
      end
    end)
  end

  defp init_storage({storage, opts}), do: {storage, opts}

  defp init_storage(storage), do: {storage, []}

  defp filter_variants(variants, image, name) do
    Enum.reject(variants, &saved?(image, name, elem(&1, 0)))
  end
end
