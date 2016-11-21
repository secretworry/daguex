defmodule Daguex.ContextHelper do

  alias Daguex.Pipeline.Context

  alias Daguex.{Image, ImageFile}

  import Daguex.Processor.StorageHelper

  def create_context(path, identifier \\ nil)

  def create_context(path, nil), do: create_context(path, create_id_from_path(path))

  def create_context(path, identifier) do
    image_file = ImageFile.from_file!(path)
    image = Image.from_image_file(image_file, identifier)
    {:ok, context} = %Context{image: image, local_storage: {TestStorage, %{}}} |> put_local_image(image_file, "orig")
    context
  end

  defp create_id_from_path(path), do: Path.basename(path, Path.extname(path))
end