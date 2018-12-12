defmodule ExDocRefined.Retriever do
  @moduledoc """
  Retrieve documents from files
  """

  def project_modules do
    Path.wildcard(Mix.Project.compile_path() <> "/*.beam")
    |> Enum.map(&%{module_name: Path.basename(&1, ".beam") |> String.to_atom(), path: &1})
    |> Enum.sort()
  end

  def project_name do
    Mix.Project.app_path()
    |> Path.basename()
    |> Macro.camelize()
  end

  def normalize_docs(module_name, docs) do
    {_, _, _, _, module_doc, _, functions} = docs

    specs = get_specs(("Elixir." <> module_name) |> String.to_atom())
    types = get_types(("Elixir." <> module_name) |> String.to_atom())

    %{
      module_name: module_name,
      module_doc: module_doc |> doc_to_html(),
      functions: normalize_functions(module_name, functions, specs, types)
    }
  end

  defp get_specs(module) do
    case Code.Typespec.fetch_specs(module) do
      {:ok, specs} -> Map.new(specs)
      _ -> %{}
    end
  end

  defp get_types(module) do
    case Code.Typespec.fetch_types(module) do
      {:ok, types} -> Enum.map(types, &elem(&1, 1))
      _ -> []
    end
  end

  defp normalize_functions(module_name, functions, specs, types) do
    functions
    |> Enum.map(&normalize_function(module_name, &1, Map.get(specs, actual_def(&1), []), types))
  end

  defp normalize_function(module_name, function, specs, types) do
    {{role, name, arity}, _line, signature, function_doc, _} = function

    type_spec =
      types
      |> Enum.find(fn {type_name, _, _} -> type_name == name end)
      |> get_type()

    %{
      module_name: module_name,
      role: role,
      name: name,
      arity: arity,
      heading: function_doc |> get_first_line(),
      args: signature |> get_arg_names(),
      signature: signature,
      specs: specs |> Enum.map(&spec_to_string(name, &1)),
      type_spec: type_spec,
      function_doc: function_doc |> doc_to_html()
    }
  end

  defp actual_def({{_, name, arity}, _, _, _, _} = function) do
    {name, arity}
  end

  def take_prefix(full, prefix) do
    base = String.length(prefix)
    String.slice(full, base, String.length(full) - base)
  end

  defp get_type(nil), do: ""

  defp get_type(type) do
    type
    |> Code.Typespec.type_to_quoted()
    |> Macro.to_string()
    |> Makeup.highlight_inner_html(lexer: "elixir")
    |> String.replace("\n", "</span><br/><span>")
  end

  defp get_first_line(:hidden = doc), do: ""
  defp get_first_line(:none = doc), do: ""

  defp get_first_line(%{"en" => doc} = _doc) do
    String.split(doc, "\n")
    |> Enum.reject(&(&1 == ""))
    |> List.first()
  end

  defp get_arg_names([] = _signature), do: []

  defp get_arg_names([signature] = _signature) do
    Regex.named_captures(~r/.*\((?<args>.*)\)/, signature)
    |> case do
      %{"args" => ""} -> []
      %{"args" => str_args} -> String.split(str_args, ",")
      _ -> []
    end
  end

  defp spec_to_string(name, spec) do
    Code.Typespec.spec_to_quoted(name, spec)
    |> Macro.to_string()
    |> Makeup.highlight_inner_html(lexer: "elixir")
  end

  defp doc_to_html(:hidden = _doc), do: ""
  defp doc_to_html(:none = _doc), do: ""

  defp doc_to_html(%{"en" => doc} = _doc) do
    markdown_to_html(doc)
  end

  defp markdown_to_html(markdown, opts \\ []) do
    options =
      struct(Earmark.Options,
        gfm: Keyword.get(opts, :gfm, true),
        line: Keyword.get(opts, :line, 1),
        file: Keyword.get(opts, :file),
        breaks: Keyword.get(opts, :breaks, false),
        smartypants: Keyword.get(opts, :smartypants, false),
        plugins: Keyword.get(opts, :plugins, %{})
      )

    Earmark.as_html!(markdown, options)
    |> ExDocRefined.Highlighter.highlight_code_blocks()
  end

  def parse_arg(arg) do
    case Code.string_to_quoted!(arg) do
      {:%{}, _, _} ->
        string_to_evalulation(arg)

      {:%, _, _} ->
        string_to_evalulation(arg)

      {{:., _, _}, _, _} ->
        string_to_evalulation(arg)

      {:fn, _, _} ->
        string_to_evalulation(arg)

      {:&, _, _} ->
        string_to_evalulation(arg)

      {:+, _, _} ->
        string_to_evalulation(arg)

      {:-, _, _} ->
        string_to_evalulation(arg)

      {:/, _, _} ->
        string_to_evalulation(arg)

      {:*, _, _} ->
        string_to_evalulation(arg)

      {:__aliases__, _, _} ->
        string_to_evalulation(arg)

      {res, _, _} ->
        to_string(res)

      res when is_atom(res) ->
        res

      res when is_integer(res) ->
        res

      res ->
        res
    end
  end

  defp string_to_evalulation(arg) do
    {res, _} = Code.eval_string(arg)

    res
  end

  def prepend_call(string, module, function, args) do
    "iex> #{module |> to_string |> take_prefix("Elixir.")}.#{function}(#{expand_args(args)}) \n\n" <>
      string
  end

  defp expand_args(args) do
    args
    |> Enum.map(&Macro.to_string/1)
    |> Enum.join(", ")
  end
end
