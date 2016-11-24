defmodule Daguex.Processor.GetImage do
  use Daguex.Processor

  import Daguex.Processor.StorageHelper

  alias Daguex.Pipeline.Context

  def init(opts) do
    %{storages: required_option(:storages)}
  end

  def process(context, %{storages: storages}) do
    format = Keyword.get(context.opts, :format)
    storages = storages |> prepend_local_storage(context)
    with {:ok, image_file} <- do_get(context.image, format, storages) do
      {:ok, context |> put_result(image_file)}
    end
  end

  defp do_get(image, format, storages) do
    Enum.find_value(storages, fn {name, storage, opts} ->
      if saved?(image, name, format) do
        key = get_key(image, name, format)
        extra = get_extra(image, name, format)
        case storage.get(key, extra, opts) do
          {:ok, path} -> Daguex.ImageFile.from_file(path)
          {:error, :not_found} -> nil
          {:error, _} = error -> error
          other -> raise "storage.get/3 should either return {:ok, path} or {:error, any}, but got #{inspect other}"
        end
      else
        nil
      end
    end) || {:error, :not_found}
  end

  defp prepend_local_storage(storages, context) do
    {storage, opts} = context.local_storage
    [{"local", storage, opts} | storages]
  end

  def put_result(context, image) do
    Context.put_private(context, __MODULE__, image)
  end

  def get_result(context) do
    Context.get_private(context, __MODULE__)
  end

end
