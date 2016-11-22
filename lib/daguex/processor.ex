defmodule Daguex.Processor do
  @moduledoc """
  Behaviour for Daguex Processors

  A processor takes a `Daguex.Pipeline.Context` and returns another `Daguex.Pipeline.Context`.
  All image converting, uploading and persisting happens via `Daguex.Processor`
  """

  @type t :: module
  @type result_t ::
      {:ok, Daguex.Pipeline.Context.t}
    | {:ok, Daguex.Pipeline.Context.t, any}
    | {:insert, Daguex.Pipeline.Context.t, t | [t]}
    | {:replace, Daguex.Pipeline.Context.t, t | [t]}
    | {:error, String.t}
  @type opts :: keyword
  @callback init(opts) :: opts
  @callback process(Daguex.Pipeline.Context.t, opts) :: result_t

  defmacro __using__(_opts) do
    quote do
      @behaviour Daguex.Processor
      import Daguex.Processor.Helper
      import Daguex.Pipeline.AsyncPostProcessor.Helper
      def init(opts), do: opts

      defoverridable [init: 1]
    end
  end
end
