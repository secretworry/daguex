defmodule Daguex.Pipeline.AsyncPostProcessor do
  @moduledoc """
  Implement async post processor for dealing with async processing
  """
  @behaviour Daguex.Pipeline.PostProcessor

  def init(_context), do: nil

  def each_result(context, {module, {:async, opts, async_fn}}, acc) do
    task = Task.start(fn->
      async_fn.(context, opts)
    end)
    {:ok, context, [task, acc]}
  end

  def each_result(context, _, acc), do: {:ok, context, acc}

  def process(context, acc) do
    Enum.each(acc, & Task.await(&1))
    {:ok, context}
  end

  defmodule Helper do
    def async(context, opts, async_fn) do
      {:ok, context, {:async, opts, async_fn}}
    end
  end
end
