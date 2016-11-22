defmodule TestRepo do
  @behaviour Daguex.Repo

  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init do
    {:ok, %{}}
  end

  def dump(image, _opts \\ []), do: GenServer.call(__MODULE__, {:dump, image})
  def load(identifier, _opts \\ []), do: GenServer.call(__MODULE__, {:load, identifier})
  def reset(), do: GenServer.cast(__MODULE__, :reset)

  def handle_call({:dump, image}, _from, state) do
    {:reply, {:ok, image}, Map.put(state, image.key, image)}
  end

  def handle_call({:load, identifier}, _from, state) do
    response = case Map.get(state, identifier) do
      nil -> {:error, :not_found}
      image -> {:ok, image}
    end
    {:reply, response, state}
  end

  def handle_cast(:reset, _state) do
    {:noreply, %{}}
  end
end
