defmodule Daguex.Processor.LoadLocalImage do
  use Daguex.Processor

  alias Daguex.Pipeline.Context

  def init(opts), do: %{local_storage: required_option(:local_storage)}


  def process(context, %{local_storage: storage}) do
    {module, opts} = invoke_local_storage(storage)
    case module.get(context.image.id, module.init(opts)) do
      {:ok, path} -> {:ok, Context.put_image_file(context, path)}
      error -> error
    end
  end

  defp invoke_local_storage({module, opts}), do: {module, module.init(opts)}

  defp invoke_local_storage(module) when is_atom(module), do: {module, []}
end