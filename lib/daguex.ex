defmodule Daguex do

  alias Dageux.{ImageFile, Image}

  @type url :: String.t
  @type format :: String.t
  @type opts :: keyword
  @type key :: String.t
  @type error :: any

  @type get_result_t :: {:ok, String.t} | {:error, :not_found} | {:error, error}
  @type resolve_result_t :: {:ok, url} | {:error, :not_found} | {:error, error}

  @callback put(ImageFile.t, key, opts) :: {:ok, key} | {:error, error}

  @callback get(key, opts) :: get_result_t
  @callback get(key, format, opts) :: get_result_t
  @callback get(Image.t, format, opts) :: get_result_t
  @callback get(Image.t, opts) :: get_result_t

  @callback resolve(key, opts) :: resolve_result_t
  @callback resolve(key, format, opts) :: resolve_result_t
  @callback resolve(Image.t, opts) :: resolve_result_t
  @callback resolve(Image.t, format, opts) :: resolve_result_t

  use Application

  @doc false
  def start(_type, _args) do
    Daguex.Supervisor.start_link()
  end

  defmodule Error do
    defexception [:message]
  end

end
