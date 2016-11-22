defmodule Daguex.Processor.GetImage do
  use Daguex.Processor

  import Daguex.Processor.StorageHelper

  alias Daguex.Pipeline.Context

  def init(opts) do
    %{storages: required_option(:storages)}
  end

  def process(context, %{storages: storages}) do
    format = Keyword.get(context.opts, :format)
    result = Enum.find_value(storages, fn {name, storage, opts} ->
      if saved?(context.image, name, format) do
        key = get_key(context.image, name, format)
        extra = get_extra(context.image, name, format)
        case storage.get(key, extra, opts) do
          {:ok, image} -> image
          {:error, :not_found} -> nil
          {:error, _} = error -> error
        end
      else
        nil
      end
    end)
    case result do
      nil -> {:error, :not_found}
      {:error, _} = error -> error
      url -> {:ok, context |> put_image(url)}
    end
  end

  def put_image(context, image) do
    Context.put_private(context, __MODULE__, image)
  end

  def get_image(context) do
    Context.get_private(context, __MODULE__)
  end

end
