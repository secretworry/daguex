defmodule Daguex.Pipeline do
  @moduledoc """
  Execute a pipeline of `Daguex.Processor`.

  A pipeline is merely a list of processors, this module defines function for
  building, modifying and executing a pipeline
  """

  alias __MODULE__
  alias Daguex.{Processor, ImageFile, Image}
  alias Daguex.Pipeline.Context

  @type processor_config :: Processor.t | {Processor.t, Processor.opts}

  @type t :: [processor_config | [processor_config]]

  @type image_type :: Image.t

  @spec run(image_type, keyword, t) :: {:ok, Image.t} | {:error, String.t}
  def run(image, opts, pipeline) do
    context = build_context(image, opts)
    pipeline
    |> List.flatten
    |> run_processors(context)
    |> post_process
  end

  defp build_context(image, opts) do
    %Pipeline.Context{
      image: image,
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
        {:error, error}
    end
  end

  defp run_processors([], context = %{done: done}) do
    {:ok, context}
  end

  defp invoke_processor({processor, opts}) when is_list(opts) do
    {processor, processor.init(opts)}
  end

  defp invoke_processor(processor) do
    {processor, []}
  end

  def post_process({:ok, context = %{done: done}}) do
    post_processors = Application.get_env(:daguex, :post_processors, [])
    done = done |> Enum.reverse
    result = post_processors |> Enum.reduce_while(context, fn post_processor, context ->
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
            {:ok, context} -> {:cont, context}
            {:error, error} -> {:halt, {:error, error}}
          end
      end
    end)
    case result do
      {:error, error} -> {:error, error}
      %{image: image} -> {:ok, image}
    end
  end

  def post_process({:error, error}), do: {:error, error}

end
