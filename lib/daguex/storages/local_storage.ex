defmodule Daguex.LocalStorage do
  @moduledoc """
  Default implementation for `Daguex.Storage` which dump images to the local dir `base_path`

  ## Valid options

  `#{__MODULE__}` supports following opts
  * base_path   - (required) the path referrencing to the base directory for saving images
  * assets_url  - (optional) the prefix for the url that would be return by `#{__MODULE__}.resolve/2`.
                  if not specified, the resolve function will return a file url
  """

  @behaviour Dageux.Storage

  def init(opts) do
    base_path = case Keyword.fetch(opts, :base_path) do
      {:ok, base_path} -> base_path
      :error -> raise ArgumentError, "base_path is required for `#{inspect __MODULE__}`"
    end
    case normalize_base_path(base_path) do
      {:ok, path} -> Keyword.put(opts, :base_path, path)
      {:error, error} -> raise ArgumentError, error
    end
  end

  def put(path, identifier, bucket \\ nil, opts) do
    base_path = get_base_path(opts)
    target_file = target_file(identifier, bucket)
    target_path = Path.join(base_path, target_file)
    target_directory = Path.dirname(target_path)
    filename = Path.basename(target_path)
    tmp_filename = "#{filename}.tmp"
    tmp_path = Path.join(target_directory, tmp_filename)
    with :ok <- File.mkdir_p(target_directory),
         :ok <- File.cp(path, tmp_path),
         :ok <- File.rename(tmp_path, target_path),
      do: {:ok, target_file}
  end

  defp target_file(identifier, bucket) do
    hash = identifier |> Base.encode32(padding: false, case: :lower) |> String.slice(0..4)
    case bucket do
      nil -> Path.join([hash, identifier])
      bucket -> Path.join([bucket, hash, identifier])
    end
  end

  def get(identifier, _extra, opts), do: get(identifier, opts)

  def get(identifier, opts) do
    base_path = get_base_path(opts)
    target_path = Path.join(base_path, identifier)
    if File.exists?(target_path) do
      {:ok, target_path}
    else
      {:error, :not_found}
    end
  end

  def resolve(identifier, _extra, opts), do: resolve(identifier, opts)
  def resolve(identifier, opts) do
    case Keyword.fetch(opts, :assets_url) do
      {:ok, assets_url} ->
        {:ok, "#{assets_url}#{identifier}"}
      :error -> {:ok, "file://" <> Path.join(get_base_path(opts), identifier)}
    end
  end

  def rm(identifier, _extra, opts), do: rm(identifier, opts)
  def rm(identifier, opts) do
    target_path = Path.join(get_base_path(opts), identifier)
    case File.rm(target_path) do
      :ok -> :ok
      {:error, :enoent} -> :ok
      error -> error
    end
  end

  defp get_base_path(opts) do
    Keyword.get(opts, :base_path)
  end

  defp normalize_base_path(base_path) do
    case base_path do
      "/" <> _ ->
        base_path = if String.ends_with?(base_path, "/"), do: base_path, else: base_path <> "/"
        {:ok, base_path}
      _ ->
        {:error, "base_path for #{inspect __MODULE__} should be an absolute path but got #{base_path}"}
    end
  end

end
