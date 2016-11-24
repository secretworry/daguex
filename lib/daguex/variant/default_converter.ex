defmodule Daguex.Variant.DefaultConverter do

  @behaviour Daguex.Variant.Converter

  import Mogrify

  alias Daguex.ImageFile

  def init([size: size] = opts) when is_binary(size), do: opts

  def init(_opts), do: raise ArgumentError, "options size is required for `#{__MODULE__}`"

  def convert(image, [size: size] = opts) do
    prefix = Keyword.get(opts, :prefix, "default_converter")
    case Daguex.TempFile.temp_file(prefix) do
      {:ok, path} ->
        open(image.uri |> to_string) |> resize_to_fill(size) |> save(path: path)
        Daguex.ImageFile.from_file(path)
      error -> {:erro, "Cannot create temporay file for #{inspect error}"}
    end
  end

end
