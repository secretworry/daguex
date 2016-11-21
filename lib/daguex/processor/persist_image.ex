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

  defp do_dump(applied_image, context, %{repo: repo} = opts, attempts \\ 0) when attempts < 10 do
    repo.dump(applied_image, context.opts) |> process_dump_result(context, opts, attempts)
  end

  defp do_dump(_image, _context, _opts, attempts) do
    {:error, {:too_many_attempts, attempts}}
  end

  defp process_dump_result({:ok, image}, context, _opts, _attempts) do
    {:ok, %{context | image: image}}
  end

  defp process_dump_result({:error, :modified}, context, %{repo: repo} = opts, attempts) do
    case repo.load(context.image.id, context.opts) do
      {:ok, new_image} -> merge_image(context.image, new_image) |> do_dump(context, opts, attempts + 1)
      {:error, :not_found} ->
        context.image |> apply_image_modifications |> do_dump(context, opts, attempts + 1)
      {:error, _} = error -> error
    end
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