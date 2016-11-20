defmodule Daguex.ImageFile do
  @moduledoc """
  Represents a image stored on a storage storage
  """
  alias __MODULE__
  @type type :: String.t # "png" | "jpeg" | "gif" | "tif"
  @type id :: String.t

  @type t :: %__MODULE__{
    path: String.t,
    id: id,
    type: type,
    width: integer,
    height: integer
  }

  defstruct path: nil, id: nil, type: nil, width: 0, height: 0

  def from_file(path, id \\ nil)
  def from_file(path, nil) when is_binary(path) do
    id = Path.basename(path, Path.extname(path))
    from_file(path, id)
  end

  def from_file(path, id) when is_binary(path) do
    try do
      image = Mogrify.open(path) |> Mogrify.verbose
      {:ok, %ImageFile{path: path, id: id, type: image.format, width: image.width |> String.to_integer, height: image.height |> String.to_integer}}
    rescue
      e ->
        {:error, e}
    end
  end

  def from_file!(path, id \\ nil) when is_binary(path) do
    case from_file(path, id) do
      {:ok, image_file} -> image_file
      {:error, e} -> raise e
    end
  end

  def default_filename(%Daguex.ImageFile{id: id, type: type, width: width, height: height}) do
    "#{id}_#{width}_#{height}#{extname(type)}"
  end

  defp extname(type) do
    case type do
      "png" -> ".png"
      "jpeg" -> ".jpg"
      "gif" -> ".gif"
      _ -> raise ArgumentError, "Unrecognizable type #{type}"
    end
  end
end
