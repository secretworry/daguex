defmodule Daguex.Processor.PersistImage do
  use Daguex.Processor

  alias Daguex.Image

  def init(opts) do
    %{repo: required_option(:repo)}
  end

  def process(context, opts) do
    applied_image = context.image |> apply_image_modifications
    do_dump(applied_image, context, opts)
  end

  defp do_dump(applied_image, context, %{repo: repo}) do
    case repo.dump(applied_image, &update_on_stale(context.image, &1), context.opts) do
      {:ok, image} -> {:ok, %{context | image: image}}
      error -> error
    end
  end

  defp update_on_stale(old_image, new_image) do
    merge_image(old_image, new_image)
  end

  defp apply_image_modifications(image) do
    image |> Image.apply_data_mod() |> Image.apply_variants_mod
  end

  defp merge_image(old_image, new_image) do
    image = Image.apply_variants_mod(old_image.viarants_mod, new_image)
    image = Image.apply_data_mod(old_image.data_mod, image)
    image
  end
end
