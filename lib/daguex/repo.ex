defmodule Daguex.Repo do
  @moduledoc """
  Behaviour for `Daguex.Repo` which in the change of persisting `Daguex.Image` and retriving it back

  For mose case, it should be backed by a external storage( a database for mose cases)
  """
  @type t :: module
  @type id :: String.t
  @type error :: any
  @type opts :: keyword


  @callback dump(Daguex.Image.t, opts) :: {:ok, Daguex.Image.t} | {:error, :modified} | {:error, error}
  @callback load(id, opts) :: {:ok, Daguex.Image.t} | {:error, :not_found} | {:error, error}
end
