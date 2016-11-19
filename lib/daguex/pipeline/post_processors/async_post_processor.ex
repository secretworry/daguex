defmodule Daguex.Pipeline.AsyncPostProcessor do
  @moduledoc """
  Implement async post processor for dealing with async processing
  """
  @behaviour Daguex.Pipeline.PostProcessor

  def init(_context), do: nil

  def each_result(context, {module, {:async, opts, async_fn, post_processor}}, acc) do
    task = Task.start(fn->
      async_fn.(context, opts)
    end)
    {:ok, context, [{task, post_processor}, acc]}
  end

  def each_result(context, _, acc), do: {:ok, context, acc}

  def process(context, acc) do
    Enum.reduce_while(acc, context, fn {task, post_processor}, context ->
      case post_processor.(context, Task.await(task)) do
        {:ok, context} -> {:cont, context}
        error -> {:halt, error}
      end
    end)
  end

  defmodule Helper do
    def async(context, opts, async_fn, post_processor) do
      {:ok, context, {:async, opts, async_fn, post_processor}}
    end
  end
end
