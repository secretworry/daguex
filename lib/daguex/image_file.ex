defmodule Daguex.ImageFile do
  @moduledoc """
  Represents a image stored on a storage storage
  """
  alias __MODULE__
  @type type :: String.t # "png" | "jpeg" | "gif" | "tif"

  @type t :: %__MODULE__{
    path: String.t,
    type: type,
    width: integer,
    height: integer
  }

  defstruct path: nil, type: nil, width: 0, height: 0

  def from_file(path) when is_binary(path) do
    try do
      image = Mogrify.open(path) |> Mogrify.verbose
      {:ok, %ImageFile{path: path, type: image.format, width: image.width |> String.to_integer, height: image.height |> String.to_integer}}
    rescue
      e ->
        {:error, e}
    end
  end

  def from_file!(path) when is_binary(path) do
    case from_file(path) do
      {:ok, image_file} -> image_file
      {:error, e} -> raise e
    end
  end
end
