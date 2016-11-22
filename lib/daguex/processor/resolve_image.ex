defmodule Daguex.Processor.ResolveImage do

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
        case storage.resolve(key, extra, opts) do
          {:ok, url} -> url
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
      url -> {:ok, context |> put_url(url)}
    end
  end

  def put_url(context, url) do
    Context.put_private(context, __MODULE__, url)
  end

  def get_url(context) do
    Context.get_private(context, __MODULE__)
  end
end
