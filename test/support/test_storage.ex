defmodule TestStorage do
  defmodule Handler do
    use GenServer
    def start_link do
      GenServer.start_link(__MODULE__, [], name: __MODULE__)
    end

    def init do
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

  def start_link do
    Handler.start_link
  end

  def init(opts), do: opts

  def put(path, id, bucket \\ nil, _opts) do
    GenServer.call(Handler, {:put, path, id, bucket})
  end

  def get(identifier, extra \\ nil, _opts) do
    GenServer.call(Handler, {:get, identifier, extra})
  end

  def resolve(identifier, extra \\ nil, _opts) do
    GenServer.call(Handler, {:resolve, identifier, extra})
  end

  def rm(identifier, extra \\ nil, _opts) do
    GenServer.call(Handler, {:rm, identifier, extra})
  end

  def reset() do
    GenServer.cast(Handler, :reset)
  end


end