defmodule Daguex.Builder.Repo do

  defmacro repo(repository) do
    repository = Macro.expand(repository, __CALLER__)
    quote do
      @repo unquote(repository)
    end
  end

end
