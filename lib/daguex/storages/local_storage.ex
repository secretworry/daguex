defmodule Daguex.LocalStorage do

  alias Daguex.ImageFile

  def init(opts) do
  end

  def do_put(base_path, path, identifier, opts) do
    target_path = Path.join(base_path, target_file(identifier, opts))
    target_directory = Path.dirname(target_path)
    filename = Path.basename(target_path)
    tmp_filename = "#{filename}.tmp"
    tmp_path = Path.join(target_directory, tmp_filename)
    with :ok <- File.mkdir_p(target_directory),
         :ok <- File.cp(path, tmp_path),
         :ok <- File.rename(tmp_path, target_path),
      do: {:ok, identifier}
  end

  defp target_file(identifier, _opts) do
    hash = identifier |> Base.encode64(padding: false)
    Path.join([hash, identifier])
  end

  def do_get(base_path, path, identifier, opts) do
    target_path = Path.join(base_path, target_file(identifier, opts))
    if File.exists?(target_path) do
      {:ok, ImageFile.from_file(target_path)}
    else
      {:error, :not_exist}
    end
  end

  def do_resolve(asset_url, identifier, opts) do
    target_file = target_file(identifier, opts)
    {:ok, "#{asset_url}#{target_file}"}
  end

  def do_rm(base_path, identifier, opts) do
    target_path = Path.join(base_path, target_file(identifier, opts))
    File.rm(target_path)
  end

end
