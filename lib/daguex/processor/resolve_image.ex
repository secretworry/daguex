defmodule Daguex.Processor.ResolveImage do

  use Daguex.Processor

  import Daguex.Processor.StorageHelper

  alias Daguex.Pipeline.Context

  def init(opts) do
    %{storages: required_option(:storages)}
  end

  def process(context, %{storages: storages}) do
    format = Keyword.get(context.opts, :format)
    with {:ok, variant} <- get_variant(context.image, format),
         {:ok, url} <- do_resolve(context.image, format, storages) do
      image_file = Daguex.ImageFile.build(url, variant["type"], variant["width"], variant["height"])
      {:ok, context |> put_result(image_file)}
    end
  end

  defp get_variant(image, format) do
    case Daguex.Image.get_variant(image, format) do
      nil -> {:error, :not_found}
      variant -> {:ok, variant}
    end
  end

  defp do_resolve(image, format, storages) do
    Enum.find_value(storages, fn {name, storage, opts} ->
      if saved?(image, name, format) do
        key = get_key(image, name, format)
        extra = get_extra(image, name, format)
        case storage.resolve(key, extra, opts) do
          {:ok, _url} = ok -> ok
          {:error, :not_found} -> nil
          {:error, _} = error -> error
          other -> raise "Storage.resolve/3 should either return {:ok, url} or {:error, any}, but got #{inspect other}"
        end
      else
        nil
      end
    end) || {:error, :not_found}
  end

  def put_result(context, image) do
    Context.put_private(context, __MODULE__, image)
  end

  def get_result(context) do
    Context.get_private(context, __MODULE__)
  end
end
