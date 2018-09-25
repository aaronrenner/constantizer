Application.put_env(:constantizer, :resolve_at_compile_time, true)
Application.put_env(:constantizer, :foo, :bar)

defmodule MyModule do
  import Constantizer

  def runtime_lookup do
    Application.get_env(:constantizer, :foo)
  end

  defconst compile_time_lookup do
    Application.get_env(:constantizer, :foo)
  end
end

Benchee.run(%{
  "runtime_lookup" => & MyModule.runtime_lookup/0,
  "compile_time_lookup" => & MyModule.compile_time_lookup/0,
})
