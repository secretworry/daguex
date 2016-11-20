defmodule Dageux.Storage do
  @moduledoc """
  Behaviour for a image storage
  """

  alias Daguex.ImageFile

  @type t :: module
  @type opts :: keyword
  @type path :: String.t
  @type bucket :: String.t
  @type id :: String.t
  @type url :: String.t
  @type error :: any
  @type extra :: any
  @type put_result_t :: {:ok, id} | {:ok, id, extra} | {:error, error}
  @type get_result_t ::  {:ok, String.t} | {:error, :not_found} | {:error, error}
  @type resolve_result_t :: {:ok, url} | {:error, :not_found} | {:error, error}
  @type rm_result_t :: :ok | {:error, error}
  @doc"""
  Initialize the options for the given storage

  This method can be used to convert options, add default options and validate the option.
  Error might be raised for an illegal option
  """
  @callback init(opts) :: opts | no_return
  @doc"""
  Put a local image to the storage

  The storage can use the given identifier to generate its own identifier, or just use and return the given one.
  The returned identifier should can be used for later actions like `get`, `resolve` and `rm`
  """
  @callback put(path, id, opts) :: put_result_t
  @callback put(path, id, bucket, opts) :: put_result_t
  @doc"""
  Get a image through `id` and `extra` returned from `#{__MODULE__}.put/3`, and save it to a local file.

  The image should be downloaded from the remote server, if it locates on a remote server. Or just return the local path,
  if it can be accessed on the server. When the image cannot be found, the storage should return `{:error, :not_found}`,
  so the invoker can handle it seperately.
  """
  @callback get(id, opts) :: get_result_t
  @callback get(id, extra, opts) :: get_result_t
  @doc"""
  Resolve the given `id` and `extra` to a user-accessible url
  """
  @callback resolve(id, opts) :: resolve_result_t
  @callback resolve(id, extra, opts) :: resolve_result_t
  @doc"""
  Remove the image identified by the given identifier from the storage

  If the targeting image doesn't exist, the api should swallow the error, and just return an `:ok`
  """
  @callback rm(id, opts) :: rm_result_t
  @callback rm(id, extra, opts) :: rm_result_t
end
