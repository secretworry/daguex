defmodule Daguex.DaguexCase do

  use ExUnit.CaseTemplate


  setup do
    TestRepo.reset()
    TestStorage.reset()
    on_exit fn ->
      TestRepo.reset()
      TestStorage.reset()
    end
  end
end