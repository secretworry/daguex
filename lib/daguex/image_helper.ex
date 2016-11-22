defmodule Daguex.ImageHelper do

  def variant_key(%Daguex.Image{} = image, format \\ nil) do
    format = case format do
      nil -> ""
      "orig" -> ""
      _ -> "#{format}_"
    end
    "#{image.key}_#{format}#{image.width}_#{image.height}#{extname(image.type)}"
  end

  def variant_key(%Daguex.ImageFile{} = image_file, key, format) do
    format = case format do
      nil -> ""
      "orig" -> ""
      _ -> "#{format}_"
    end
    "#{key}_#{format}#{image_file.width}_#{image_file.height}#{extname(image_file.type)}"
  end

  def extname(type) do
    case type do
      "png" -> ".png"
      "jpeg" -> ".jpg"
      "gif" -> ".gif"
      _ -> raise ArgumentError, "Unrecognizable type #{type}"
    end
  end
end
