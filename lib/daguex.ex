defmodule Daguex do

  alias Dageux.{ImageFile, Image}

  @type url :: String.t
  @type format :: String.t
  @type opts :: keyword
  @type id :: String.t
  @type error :: any

  @callback put(ImageFile.t, id, opts) :: {:ok, id} | {:error, error}
  @callback get(id, format, opts) :: {:ok, String.t} | {:error, :not_found} | {:error, error}
  @callback resolve(id, format, opts) :: {:ok, url} | {:error, :not_found} | {:error, error}

  use Application

  @doc false
  def start(_type, _args) do
    Daguex.Supervisor.start_link()
  end

  defmodule Error do
    defexception [:message]
  end

end
