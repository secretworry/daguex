defmodule DummyStorage do
  defmodule Handler do
    use GenServer
    def start_link do
      GenServer.start_link(__MODULE__, [], name: __MODULE__)
    end

    def init do
      {:ok, %{}}
    end

    def handle_call({:put, identifier, path}, _from, state) do
      {:reply, {:ok, identifier}, Map.put(state, identifier, path)}
    end

    def handle_call({:get, identifier}, _from, state) do
      result = case Map.get(state, identifier) do
        nil -> {:error, :not_found}
        path -> {:ok, path}
      end
      {:reply, result, state}
    end

    def handle_call({:resolve, identifier}, _from, state) do
      result = case Map.get(state, identifier) do
        nil -> {:error, :not_found}
        path -> {:ok, "file://" <> path}
      end
      {:reply, result, state}
    end

    def handle_call({:rm, identifier}, _from, state) do
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

  def put(identifier, path, _opts) do
    GenServer.call(Handler, {:put, identifier, path})
  end

  def get(identifier, _opts) do
    GenServer.call(Handler, {:get, identifier})
  end

  def resolve(identifier, _opts) do
    GenServer.call(Handler, {:resolve, identifier})
  end

  def rm(identifier, _opts) do
    GenServer.call(Handler, {:rm, identifier})
  end

  def reset() do
    GenServer.cast(Handler, :reset)
  end


end