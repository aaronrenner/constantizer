defmodule Constantizer do
  @moduledoc """
  Constantizer is a library for turning functions into constants.
  """

  @doc """
  Defines a public constant
  """
  defmacro defconst(name, do: block) do
    do_def(name, block, __CALLER__, :public)
  end

  @doc """
  Defines a private constant.
  """
  defmacro defconstp(name, do: block) do
    do_def(name, block, __CALLER__, :private)
  end

  defp do_def(name, block, env, visibility) do
    if resolve_at_compile_time?() do
      {result, _} = Code.eval_quoted(block, [], env)

      dynamic_def(
        visibility,
        name,
        quote do
          # Avoid unused alias warnings
          _ = fn -> unquote(block) end

          unquote(result)
        end
      )
    else
      dynamic_def(
        visibility,
        name,
        quote do
          unquote(block)
        end
      )
    end
  end

  defp dynamic_def(:private, name, ast) do
    quote do
      defp unquote(name), do: unquote(ast)
    end
  end

  defp dynamic_def(:public, name, ast) do
    quote do
      def unquote(name), do: unquote(ast)
    end
  end

  defp resolve_at_compile_time? do
    Application.get_env(:constantizer, :resolve_at_compile_time, true)
  end
end
