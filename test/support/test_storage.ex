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

    def handle_call({:put, path, id, _bucket}, _from, state) do
      {:reply, {:ok, id}, Map.put(state, id, path)}
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

  def put(path, id, bucket \\ nil, opts) do
    GenServer.call(get_pid(opts), {:put, path, id, bucket})
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