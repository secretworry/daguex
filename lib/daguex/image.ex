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
    %{image | variants: Map.put(variants, format, %{id: id, width: width, height: height, type: type})}
  end

  def put_data(image = %__MODULE__{data_mod: data_mod}, keys, value) do
  end

  def rm_data(image = %__MODULE__{data_mod: data_mod}, keys) do
  end

  def get_data(image = %__MODULE__{data: data, data_mod: data_mod}, keys, default_vaule \\ nil) do
  end

end
