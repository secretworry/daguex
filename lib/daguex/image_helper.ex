defmodule Daguex.ImageHelper do

  def variant_id(%Daguex.Image{} = image, format \\ nil) do
    format = case format do
      nil -> ""
      "orig" -> ""
      _ -> "#{format}_"
    end
    "#{image.id}_#{format}#{image.width}_#{image.height}#{extname(image.type)}"
  end

  def variant_id(%Daguex.ImageFile{} = image_file, id, format) do
    format = case format do
      nil -> ""
      "orig" -> ""
      _ -> "#{format}_"
    end
    "#{id}_#{format}#{image_file.width}_#{image_file.height}#{extname(image_file.type)}"
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
