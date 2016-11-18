defmodule Daguex.Pipeline.Context do
  @moduledoc """
  This module defines the context for `Dageux.Processor` to process.

  This module defines a `#{__MODULE__}` struct and the main functions for working with it.

  * `image`   - the local image that can be used for further processing,
                and for keeping necessay meta data that should be persisted
  * `opts`    - the options passed to the pipeline
  * `private` - shared data across different processor
  * `done`    - an array contains all the executed processores and their
                corresponding result
  """

  @type done_t :: {module, any()}
  @type t :: %__MODULE__{
    image: Dageux.Image.t,
    opts: keyword,
    private: Map.t,
    done: [done_t]
  }

  @enforce_keys [:image]
  defstruct [
    image: nil,
    opts: [],
    private: %{},
    done: []
  ]

  alias __MODULE__


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
