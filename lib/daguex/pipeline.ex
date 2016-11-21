defmodule Daguex.Pipeline do
  @moduledoc """
  Execute a pipeline of `Daguex.Processor`.

  A pipeline is merely a list of processors, this module defines function for
  building, modifying and executing a pipeline
  """

  alias __MODULE__
  alias Daguex.{Processor, Image}
  alias Daguex.Pipeline.Context

  @type processor_config :: Processor.t | {Processor.t, Processor.opts}

  @type t :: [processor_config | [processor_config]]

  @type local_storage :: {Daguex.Storage.t, any}

  @type error :: any

  @spec run(Image.t, local_storage, keyword, t) :: {:ok, Image.t} | {:error, error}
  def run(image, local_storage, opts, pipeline) do
    context = build_context(image, local_storage, opts)
    pipeline
    |> List.flatten
    |> run_processors(context)
    |> post_process
    |> get_image
  end


  @spec call(Context.t, t) :: {:ok, Context.t} | {:error, error}
  def call(context, pipeline) do
    pipeline
    |> List.flatten
    |> run_processors(context)
    |> post_process
  end

  defp build_context(image, local_storage, opts) do
    %Pipeline.Context{
      image: image,
      local_storage: local_storage,
      opts: opts
    }
  end

  defp run_processors([processor_config | remaining], context) do
    {processor, options} = invoke_processor(processor_config)
    case processor.process(context, options) do
      {:ok, context} ->
        run_processors(remaining, context |> Context.done(processor))
      {:ok, context, result} ->
        run_processors(remaining, context |> Context.done(processor, result))
      {:insert, context, extra} ->
        run_processors(List.wrap(extra) ++ remaining, context |> Context.done(processor))
      {:replace, context, replacement} ->
        run_processors(replacement, context |> Context.done(processor))
      {:error, error} ->
        {:error, error, context}
    end
  end

  defp run_processors([], context) do
    {:ok, context}
  end

  defp invoke_processor({processor, opts}) do
    {processor, opts}
  end

  defp invoke_processor(processor) do
    {processor, []}
  end

  def post_process({:ok, context = %{done: done}}) do
    post_processors = Application.get_env(:daguex, :post_processors, [])
    done = done |> Enum.reverse
    post_processors |> Enum.reduce_while({:ok, context}, fn post_processor, {:ok, context} ->
      init = post_processor.init(context)
      case Enum.reduce_while(done, {context, init}, fn item, {context, acc} ->
        case post_processor.each_result(context, item, acc) do
          {:ok, context, acc} -> {:cont, {context, acc}}
          {:error, error} -> {:halt, {:error, error}}
          _ -> raise "#{post_processor}.each_result/3 should return either {:ok, context, result} or {:error, error}"
        end
      end) do
        {:error, error} -> {:halt, {:error, error}}
        {context, acc} ->
          case post_processor.process(context, acc) do
            {:ok, context} -> {:cont, {:ok, context}}
            {:error, error} -> {:halt, {:error, error}}
          end
      end
    end)
  end

  def post_process({:error, error, _context}), do: {:error, error}

  def get_image({:ok, context}), do: {:ok, context.image}

  def get_image({:error, _} = error), do: error

end
