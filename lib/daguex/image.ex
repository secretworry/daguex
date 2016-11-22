defmodule Daguex.Image do

  @type key :: String.t
  @type variant_t :: %{identifier: identifier, width: integer, height: integer, type: Daguex.ImageFile.type}
  @type format :: String.t

  @type t :: %__MODULE__{
    key: key,
    width: integer,
    height: integer,
    type: String.t,
    variants: %{format => variant_t},
    variants_mod: %{format => variant_t | :removed},
    data: Map.t,
    data_mod: Map.t
  }

  @enforce_keys [:key, :width, :height, :type]
  defstruct [
    key: nil,
    width: 0,
    height: 0,
    type: nil,
    variants: %{},
    variants_mod: %{},
    data: %{},
    data_mod: %{}
  ]

  def from_image_file(%Daguex.ImageFile{} = image_file, key) do
    %__MODULE__{key: key, width: image_file.width, height: image_file.height, type: image_file.type}
  end

  @spec add_variant(t, format, key, integer, integer, Daguex.ImageFile.type) :: t
  def add_variant(image = %__MODULE__{variants_mod: variants_mod}, format, key, width, height, type) do
    %{image | variants_mod: Map.put(variants_mod, format, build_variant(key, width, height, type))}
  end

  defp build_variant(key, width, height, type) do
    %{"key" => key, "width" => width, "height" => height, "type" => type}
  end

  def rm_variant(image = %__MODULE__{variants_mod: variants_mod}, format) do
    %{image | variants_mod: Map.put(variants_mod, format, :removed)}
  end

  def get_variant(%__MODULE__{variants: variants, variants_mod: variants_mod}, format) do
    case Map.get(variants_mod, format) do
      :removed -> nil
      nil -> Map.get(variants, format)
      variant -> variant
    end
  end

  def has_variant?(%__MODULE__{variants: variants, variants_mod: variants_mod}, format) do
    case Map.get(variants_mod, format) do
      :removed -> nil
      nil -> Map.has_key?(variants, format)
      _ -> true
    end
  end

  def apply_variants_mod(image_or_mod, target_image \\ nil)

  def apply_variants_mod(%__MODULE__{variants: variants, variants_mod: variants_mod} = image, nil) do
    %{image | variants: do_apply_variants_mod(variants_mod, variants), variants_mod: %{}}
  end

  def apply_variants_mod(mod, %__MODULE__{variants: variants} = image) do
    %{image | variants: do_apply_variants_mod(mod, variants), variants_mod: %{}}
  end

  defp do_apply_variants_mod(mod, variants) do
    Enum.reduce(mod, variants, fn
      {key, :removed}, variants -> Map.delete(variants, key)
      {key, value}, variants -> Map.put(variants, key, value)
    end)
  end

  def variants(%__MODULE__{variants: variants, variants_mod: variants_mod}) do
    do_apply_variants_mod(variants_mod, variants)
  end

  def variants_with_origal(image) do
    variants(image) |> Map.put("orig", build_variant(image.key, image.width, image.height, image.type))
  end

  def put_data(image = %__MODULE__{data_mod: data_mod}, keys, value) do
    %{image | data_mod: do_put_data(data_mod, keys, value)}
  end

  def rm_data(image, keys) do
    put_data(image, keys, :removed)
  end

  def get_data(%__MODULE__{data: data, data_mod: data_mod}, keys, default_value \\ nil) do
    case do_get_data(data_mod, keys) do
      :removed -> default_value
      nil -> do_get_data(data, keys)
      value -> value
    end
  end

  def apply_data_mod(image_or_mod, target_image \\ nil)

  def apply_data_mod(%__MODULE__{data_mod: data_mod} = image, nil) do
    apply_data_mod(data_mod, image)
  end

  def apply_data_mod(mod, %__MODULE__{data: data} = image) do
    %{image| data: do_apply_mod(mod, data), data_mod: %{}}
  end

  defp do_put_data(data, [key|tail], value) do
    data = case data do
      map when is_map(map) -> data
      _ -> %{}
    end
    Map.put(data, key, do_put_data(Map.get(data, key), tail, value))
  end

  defp do_put_data(_data, [], value), do: value

  defp do_get_data(:removed, _), do: :removed

  defp do_get_data(nil, _), do: nil

  defp do_get_data(data, [key|tail]) do
    case data do
      map when is_map(map) -> do_get_data(Map.get(data, key), tail)
      _ -> nil
    end
  end

  defp do_get_data(data, []), do: data

  defp do_apply_mod(nil, data), do: data
  defp do_apply_mod(mod, nil), do: do_apply_mod(mod, %{})

  defp do_apply_mod(mod, data) when is_map(mod) do
    Enum.reduce(mod, data, fn
      {key, :removed}, data -> Map.delete(data, key)
      {key, map}, data when is_map(map) -> Map.put(data, key, do_apply_mod(map, Map.get(data, key)))
      {key, value}, data -> Map.put(data, key, value)
    end)
  end
end
