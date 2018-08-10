# credo:disable-for-this-file Credo.Check.Design.AliasUsage
defmodule ConstantizerTest do
  use ExUnit.Case

  describe "when :resolve_at_compile_time is true" do
    setup do
      ensure_env_is_reset(:constantizer, :resolve_at_compile_time)
      Application.put_env(:constantizer, :resolve_at_compile_time, true)

      assert capture_err(fn ->
               Code.eval_string("""
               defmodule ConstantizerTest.ResolvedConsts do
                 import Constantizer

                 alias ExUnit.Assertions

                 defconst public_const do
                   _ = Assertions
                   send self(), :called
                   :public_const_return
                 end

                 def call_private, do: private_const()

                 defconstp private_const do
                   send self(), :private_called
                   :private_const_return
                  end
               end
               """)
             end) == ""

      purge_on_exit(ConstantizerTest.ResolvedConsts)
      flush()

      :ok
    end

    test "defconst does not run the function at runtime" do
      assert :public_const_return = ConstantizerTest.ResolvedConsts.public_const()

      refute_received :called
    end

    test "defconstp does not run the function at runtime" do
      assert :private_const_return = ConstantizerTest.ResolvedConsts.call_private()

      refute_received :private_called
    end
  end

  describe "when :resolve_at_compile_time is false" do
    setup do
      ensure_env_is_reset(:constantizer, :resolve_at_compile_time)
      Application.put_env(:constantizer, :resolve_at_compile_time, false)

      assert capture_err(fn ->
               Code.eval_string("""
               defmodule ConstantizerTest.UnresolvedConsts do
                 import Constantizer

                 alias ExUnit.Assertions

                 defconst public_const do
                   send self(), :called
                   :public_const_return
                 end

                 def call_private_const, do: private_const()

                 defconstp private_const do
                   _ = Assertions
                   send self(), :private_called
                   :private_const_return
                 end

               end
               """)
             end) == ""

      purge_on_exit(ConstantizerTest.UnresolvedConsts)
      :ok
    end

    test "defconst runs the function at runtime" do
      assert :public_const_return = ConstantizerTest.UnresolvedConsts.public_const()

      assert_received :called
    end

    test "defconstp runs the function at runtime" do
      assert :private_const_return = ConstantizerTest.UnresolvedConsts.call_private_const()

      assert_received :private_called
    end
  end

  defp capture_err(fun) do
    ExUnit.CaptureIO.capture_io(:stderr, fun)
  end

  defp ensure_env_is_reset(app, setting) do
    original_result = Application.fetch_env(app, setting)

    on_exit(fn ->
      case original_result do
        {:ok, val} -> Application.put_env(app, setting, val)
        :error -> Application.delete_env(app, setting)
      end
    end)
  end

  defp purge_on_exit(module) do
    on_exit(fn -> purge(module) end)
  end

  defp purge(module) do
    :code.purge(module)
    :code.delete(module)
  end

  defp flush do
    receive do
      _ -> flush()
    after
      0 -> :ok
    end
  end
end
