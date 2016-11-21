defmodule Daguex.ContextHelper do

  alias Daguex.Pipeline.Context

  alias Daguex.{Image, ImageFile}

  def create_context(path, identifier \\ nil)

  def create_context(path, nil), do: create_context(path, create_id_from_path(path))

  def create_context(path, identifier) do
    {:ok, identifier} = TestStorage.put(path, identifier, %{})
    image_file = ImageFile.from_file!(path)
    image = %Image{id: identifier, width: image_file.width, height: image_file.height, type: image_file.type}
    %Context{image: image, image_file: image_file, local_storage: {TestStorage, %{}}}
  end

  defp create_id_from_path(path), do: Path.basename(path, Path.extname(path))
end