defmodule Daguex.DaguexCase do

  use ExUnit.CaseTemplate


  setup do
    TestRepo.reset()
    TestStorage.reset(%{pid: TestStorage.Handler})
    on_exit fn ->
      TestRepo.reset()
      TestStorage.reset(%{pid: TestStorage.Handler})
    end
  end
end