defmodule Daguex.Pipeline.AsyncPostProcessor do
  @moduledoc """
  Implement async post processor for dealing with async processing
  """
  @behaviour Daguex.Pipeline.PostProcessor

  def init(_context), do: []

  def each_result(context, {_module, {:async, opts, async_fn, post_processor}}, acc) do
    task = Task.async(fn->
      async_fn.(context, opts)
    end)
    {:ok, context, [{task, post_processor}|acc]}
  end

  def each_result(context, _, acc), do: {:ok, context, acc}

  def process(context, acc) do
    Enum.reduce_while(acc, {:ok, context}, fn {task, post_processor}, {:ok, context} ->
      with {:ok, payload} <- Task.await(task),
           {:ok, context} <- post_processor.(context, payload) do
        {:cont, {:ok, context}}
      else
        error -> {:halt, error}
      end
    end)
  end

  defmodule Helper do
    alias Daguex.Pipeline.Context
    @type async_result_t :: {:ok, any} | {:error, any}
    @type post_result_t :: {:ok, Context.t} | {:error, any}
    @type async_fn :: (Context.t, any -> async_result_t)
    @type post_processor :: (Context.t, any -> post_result_t)
    @type result_t :: {:ok, Context.t}
    @spec async(Context.t, any, async_fn, post_processor) :: {:ok, Context.t, {:async, any, async_fn, post_processor}}
    def async(context, opts, async_fn, post_processor) do
      {:ok, context, {:async, opts, async_fn, post_processor}}
    end
  end
end
