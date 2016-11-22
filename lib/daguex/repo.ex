defmodule Daguex.Repo do
  @moduledoc """
  Behaviour for `Daguex.Repo` which in the change of persisting `Daguex.Image` and retriving it back

  For mose case, it should be backed by a external storage( a database for mose cases)
  """
  @type t :: module
  @type key :: String.t
  @type error :: any
  @type opts :: keyword
  @type dump_t :: {:ok, Daguex.Image.t} | {:error, :modified} | {:error, error}
  @type load_t :: {:ok, Daguex.Image.t} | {:error, :not_found} | {:error, error}


  @callback dump(Daguex.Image.t) :: dump_t
  @callback dump(Daguex.Image.t, opts) :: dump_t
  @callback load(key) :: load_t
  @callback load(key, opts) :: load_t
end
