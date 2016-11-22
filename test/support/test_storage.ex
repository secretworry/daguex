defmodule TestStorage do
  defmodule Handler do
    use GenServer
    def start_link(opts) do
      GenServer.start_link(__MODULE__, [], opts)
    end

    def start(opts) do
      GenServer.start(__MODULE__, [], opts)
    end

    def init(_args) do
      {:ok, %{}}
    end

    def handle_call({:put, path, key, bucket}, _from, state) do
      key = case bucket do
        nil -> key
        _ -> "#{bucket}/#{key}"
      end
      {:reply, {:ok, key}, Map.put(state, key, path)}
    end

    def handle_call({:get, identifier, _extra}, _from, state) do
      result = case Map.get(state, identifier) do
        nil -> {:error, :not_found}
        path -> {:ok, path}
      end
      {:reply, result, state}
    end

    def handle_call({:resolve, identifier, _extra}, _from, state) do
      result = case Map.get(state, identifier) do
        nil -> {:error, :not_found}
        path -> {:ok, "file://" <> path}
      end
      {:reply, result, state}
    end

    def handle_call({:rm, identifier, _extra}, _from, state) do
      {:reply, :ok, Map.delete(state, identifier)}
    end

    def handle_call(:dump, _from, state) do
      {:reply, state, state}
    end

    def handle_cast(:reset, _state) do
      {:noreply, %{}}
    end
  end

  alias __MODULE__

  def start(opts \\ []) do
    Handler.start(opts)
  end

  def start_link(opts \\ []) do
    Handler.start_link(opts)
  end

  def init(opts) do
    %{pid: Keyword.get(opts, :pid, Handler)}
  end

  def put(path, key, bucket \\ nil, opts) do
    GenServer.call(get_pid(opts), {:put, path, key, bucket})
  end

  def get(identifier, extra \\ nil, opts) do
    GenServer.call(get_pid(opts), {:get, identifier, extra})
  end

  def resolve(identifier, extra \\ nil, opts) do
    GenServer.call(get_pid(opts), {:resolve, identifier, extra})
  end

  def rm(identifier, extra \\ nil, opts) do
    GenServer.call(get_pid(opts), {:rm, identifier, extra})
  end

  def reset(opts \\ nil) do
    GenServer.cast(get_pid(opts), :reset)
  end

  def dump(opts \\ nil) do
    GenServer.call(get_pid(opts), :dump)
  end

  def stop(opts) do
    GenServer.stop(get_pid(opts))
  end

  defp get_pid(%{pid: pid}) do
    pid
  end

  defp get_pid(_) do
    TestStorage.Handler
  end
end
