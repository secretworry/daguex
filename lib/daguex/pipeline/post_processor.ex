defmodule Daguex.Pipeline.PostProcessor do
  @moduledoc """
  Behaviour for `Daguex.Pipeline.PostProcessor`

  A post processor reduce the result of each processor into a data, and process
  the accumulated data. Async processing, batch processing can be implemented
  using this.
  """

  alias Dageux.Pipeline.Context

  @type t :: module

  @callback init(Context.t) :: any()
  @callback each_result(Context.t, Context.done_t, any()) :: {:ok, Context.t, any()} | {:error, String.t}
  @callback process(Context.t, any()) :: {:ok, Context.t} | {:error, String.t}
end
