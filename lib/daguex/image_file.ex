defmodule Daguex.ImageFile do
  @moduledoc """
  Represents a image stored on a storage storage
  """
  alias __MODULE__
  @type type :: String.t # "png" | "jpeg" | "gif" | "tif"

  @type t :: %__MODULE__{
    uri: URI.t,
    type: type,
    width: integer,
    height: integer
  }

  defstruct uri: nil, type: nil, width: 0, height: 0

  def build(uri, type, width, height) when is_binary(uri) do
    build(uri |> URI.parse, type, width, height)
  end

  def build(uri = %URI{}, type, width, height) do
    %Daguex.ImageFile{uri: uri, type: type, width: width, height: height}
  end

  def from_file(path) when is_binary(path) do
    try do
      image = Mogrify.open(path) |> Mogrify.verbose
      uri = Path.expand(path, File.cwd!) |> URI.parse
      {:ok, %ImageFile{uri: uri, type: image.format, width: image.width |> String.to_integer, height: image.height |> String.to_integer}}
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

  def local?(%__MODULE__{uri: %{scheme: scheme}} = image) do
    case scheme do
      nil -> true
      "file" -> true
      _ -> false
    end
  end
end
