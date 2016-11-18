defmodule Daguex.Variant do
  @moduledoc """
  Represents a variant of a image, including its format, and the converter to convert it
  """

  alias __MODULE__

  @type format :: atom

  @type opts :: keyword

  @type converter :: Variant.Converter.t | atom

  @type t :: %__MODULE__{
    format: format,
    converter: converter,
    opts: opts
  }

  @enforce_keys [:format, :converter, :opts]
  defstruct [
    format: nil,
    converter: nil,
    opts: []
  ]

  defmodule Converter do
    @moduledoc """
    Behaviour for `Daguex.Variant.Converter`

    The converter in the charge of converting image to a specified format
    """

    @type t :: module
    @type opts :: keyword
    @type error :: any

    @callback init(opts) :: opts

    @callback convert(Daguex.ImageFile.t, opts) :: {:ok, Daguex.ImageFile.t} | {:error, error}
  end

end