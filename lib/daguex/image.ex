defmodule Daguex.Image do

  @type id :: String.t
  @type variant_t :: %{identifier: identifier, width: integer, height: integer, type: Daguex.ImageFile.type}
  @type format :: String.t

  @type t :: %__MODULE__{
    id: id,
    width: integer,
    height: integer,
    variants: %{format => variant_t},
    data: Map.t,
    data_mod: Map.t
  }

  @enforce_keys [:id, :width, :height]
  defstruct [
    id: nil,
    width: 0,
    height: 0,
    variants: %{},
    data: %{},
    data_mod: %{}
  ]

  @spec add_variant(t, format, id, integer, integer, Daguex.ImageFile.type) :: t
  def add_variant(image = %__MODULE__{variants: variants}, format, id, width, height, type) do
    %{image | variants: Map.put(variants, format, %{"id" => id, "width" => width, "height" => height, "type" => type})}
  end

  def put_data(image = %__MODULE__{data_mod: data_mod}, keys, value) do
    %{image | data_mod: do_put_data(data_mod, keys, value)}
  end

  def rm_data(image, keys) do
    put_data(image, keys, :removed)
  end

  def get_data(image = %__MODULE__{data: data, data_mod: data_mod}, keys, default_value \\ nil) do
    case do_get_data(data_mod, keys) do
      :removed -> default_value
      nil -> do_get_data(data, keys)
      value -> value
    end
  end

  def apply_data_mod(image_or_mod, target_image \\ nil)

  def apply_data_mod(%__MODULE__{data: data, data_mod: data_mod} = image, nil) do
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

  defp do_put_data(data, [], value), do: value

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
