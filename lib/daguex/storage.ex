defmodule Dageux.Storage do
  @moduledoc """
  Behaviour for a image storage
  """

  alias Daguex.ImageFile

  @type t :: module
  @type opts :: keyword
  @type path :: String.t
  @type id :: String.t
  @type url :: String.t
  @type error :: any
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
  @callback put(id, path, opts) :: {:ok, id} | {:error, error}
  @doc"""
  Get a image from , and save it to a local file.

  The image should be downloaded from the remote server, if it locates on a remote server. Or just return the local path,
  if it can be accessed on the server. When the image cannot be found, the storage should return `{:error, :not_found}`,
  so the invoker can handle it seperately.
  """
  @callback get(id, opts) :: {:ok, String.t} | {:error, :not_found} | {:error, error}
  @doc"""
  Resolve the given identifier to a user-accessible url
  """
  @callback resolve(id, opts) :: {:ok, url} | {:error, :not_found} | {:error, error}
  @doc"""
  Remove the image identified by the given identifier from the storage

  If the targeting image doesn't exist, the api should swallow the error, and just return a `:ok`
  """
  @callback rm(id, opts) :: :ok | {:error, error}
end
