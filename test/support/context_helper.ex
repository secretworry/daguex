defmodule Daguex.ContextHelper do

  alias Daguex.Pipeline.Context

  alias Daguex.{Image, ImageFile}

  def create_context(path, identifier \\ nil)

  def create_context(path, nil), do: create_context(path, create_id_from_path(path))

  def create_context(path, identifier) do
    {:ok, identifier} = TestStorage.put(identifier, path, [])
    image_file = ImageFile.from_file!(path)
    image = %Image{id: identifier, width: image_file.width, height: image_file.height}
    %Context{image: image}
  end

  defp create_id_from_path(path), do: Path.basename(path, Path.extname(path))
end