defmodule Daguex.Pipeline.Context do
  @moduledoc """
  This module defines the context for `Dageux.Processor` to process.

  This module defines a `#{__MODULE__}` struct and the main functions for working with it.

  * `image`       - the image object that can be used for identifying specified image,
                    and for keeping necessay meta data that should be persisted
  * `image_file`  - a reference to local accessible image file
  * `opts`        - the options passed to the pipeline
  * `private`     - shared data across different processor
  * `done`        - an array contains all the executed processores and their
                corresponding result
  """

  @type done_t :: {module, any()}
  @type t :: %__MODULE__{
    image: Dageux.Image.t,
    image_file: Daguex.ImageFile.t,
    opts: keyword,
    private: Map.t,
    done: [done_t]
  }

  @enforce_keys [:image]
  defstruct [
    image: nil,
    image_file: nil,
    opts: [],
    private: %{},
    done: []
  ]

  alias __MODULE__

  @doc """
  Set image_file for the context

  Use a file path or `Daguex.ImageFile` to update the image_file
  """
  @spec put_image_file(t, String.t | Daguex.ImageFile.t) :: t
  def put_image_file(context = %Context{}, path) when is_binary(path) do
    case Daguex.ImageFile.from_file(path) do
      {:ok, image_file} -> %{context | image_file: image_file}
      {:error, error} -> raise ArgumentError, "Cannot create `#{__MODULE__}` from `#{path}` for `#{inspect error}`"
    end
  end

  def put_image_file(context = %Context{}, image_file = %Daguex.ImageFile{}) do
    %{context | image_file: image_file}
  end


  @doc """
  Assigns a new **private** key and value in the context.

  This storage is meant to be used by processors and frameworks to avoid writing
  to the image data files.
  """
  def put_private(context = %Context{private: private}, key, value) when is_atom(key) do
    %{context | private: Map.put(private, key, value)}
  end

  @doc """
  Prepends an executed processor to the done fields of the context
  """
  def done(context = %Context{done: done}, processor, result \\ :ok) when is_atom(processor) do
    %{context | done: [{processor, result}|done]}
  end
end
