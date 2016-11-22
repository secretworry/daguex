defmodule Daguex.TempFileError do
  defexception [:message]
end

defmodule Daguex.TempFile do
  @moduledoc false

  @moduledoc """
  A server (a `GenServer` specifically) that manages temporary files

  Temporary files are stored in a temporary directory
  and removed from that directory after the process that
  requested the file dies.
  """

  use GenServer

  @table __MODULE__
  @max_attempts 10
  @temp_env_vars ~w(DAGUEX_TMPDIR TMPDIR TMP TEMP)s

  @doc """
  Requests a random temporary file to be created in the tmp directory
  with the given prefix.
  """
  @spec temp_file(binary) ::
        {:ok, binary} |
        {:too_many_attempts, binary, pos_integer} |
        {:no_tmp, [binary]}
  def temp_file(prefix) do
    case ensure_tmp() do
      {:ok, tmp, paths} ->
        open_random_file(prefix, tmp, 0, paths)
      {:no_tmp, tmps} ->
        {:no_tmp, tmps}
    end
  end

  defp ensure_tmp() do
    pid = self()
    server = temp_file_server()

    case :ets.lookup(@table, pid) do
      [{^pid, tmp, paths}] ->
        {:ok, tmp, paths}
      [] ->
        {:ok, tmps} = GenServer.call(server, :register)
        {mega, _, _} = :os.timestamp
        subdir = "/daguex-" <> i(mega)

        if tmp = Enum.find_value(tmps, &make_tmp_dir(&1 <> subdir)) do
          true = :ets.insert_new(@table, {pid, tmp, []})
          {:ok, tmp, []}
        else
          {:no_tmp, tmps}
        end
    end
  end

  defp make_tmp_dir(path) do
    case File.mkdir_p(path) do
      :ok -> path |> Path.expand
      {:error, _} -> nil
    end
  end

  defp open_random_file(prefix, tmp, attempts, paths) when attempts < @max_attempts do
    path = path(prefix, tmp)

    case :file.write_file(path, "", [:write, :raw, :exclusive, :binary]) do
      :ok ->
        :ets.update_element(@table, self(), {3, [path|paths]})
        {:ok, path}
      {:error, reason} when reason in [:eexist, :eacces] ->
        open_random_file(prefix, tmp, attempts + 1, paths)
    end
  end

  defp open_random_file(_prefix, tmp, attempts, _paths) do
    {:too_many_attempts, tmp, attempts}
  end

  defp path(prefix, tmp) do
    {_mega, sec, micro} = :os.timestamp
    scheduler_id = :erlang.system_info(:scheduler_id)
    tmp <> "/" <> prefix <> "-" <> i(sec) <> "-" <> i(micro) <> "-" <> i(scheduler_id)
  end

  @compile {:inline, i: 1}
  defp i(integer), do: Integer.to_string(integer)

  @doc """
  Requests a random file to be created in the upload directory
  with the given prefix. Raises on failure.
  """
  @spec temp_file!(binary) :: binary | no_return
  def temp_file!(prefix) do
    case temp_file(prefix) do
      {:ok, path} ->
        path
      {:too_many_attempts, tmp, attempts} ->
        raise Daguex.TempFileError, "tried #{attempts} times to create an temporary file at #{tmp} but failed. " <>
                                "Set DAGUEX_TMPDIR to a directory with write permission"
      {:no_tmp, _tmps} ->
        raise Daguex.TempFileError, "could not create a tmp directory to store temporary files. " <>
                                "Set DAGUEX_TMPDIR to a directory with write permission"
    end
  end

  defp temp_file_server do
    Process.whereis(__MODULE__) ||
      raise Daguex.TempFileError, "could not find process #{inspect __MODULE__}. Have you started the :daguex application?"
  end

  @doc """
  Starts the temperory file handling server.
  """
  def start_link() do
    GenServer.start_link(__MODULE__, :ok, [name: __MODULE__])
  end

  ## Callbacks

  def init(:ok) do
    tmp = Enum.find_value @temp_env_vars, "/tmp", &System.get_env/1
    cwd = Path.join(File.cwd!, "tmp")
    :ets.new(@table, [:named_table, :public, :set])
    {:ok, [tmp, cwd]}
  end

  def handle_call(:register, {pid, _ref}, dirs) do
    Process.monitor(pid)
    {:reply, {:ok, dirs}, dirs}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    case :ets.lookup(@table, pid) do
      [{pid, _tmp, paths}] ->
        :ets.delete(@table, pid)
        Enum.each paths, &:file.delete/1
      [] ->
        :ok
    end
    {:noreply, state}
  end

  def handle_info(msg, state) do
    super(msg, state)
  end
end