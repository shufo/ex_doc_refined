defmodule ExDocRefined.V1WebSocketHandler do
  @behaviour :cowboy_websocket_handler
  alias ExDocRefined.Retriever

  def init(_, req, _opts) do
    opts = %{idle_timeout: 60000}

    {:upgrade, :protocol, :cowboy_websocket, req, opts}
  end

  def websocket_init(_transport, req, state) do
    message = %{modules: Retriever.project_modules(), project_name: Retriever.project_name()}

    send(self(), {:text, message})

    {:ok, req, %{state: state, proxy: nil}, 60_000}
  end

  def websocket_terminate(_reason, _req, _state) do
    :ok
  end

  def websocket_handle({:text, "{\"module_path\"" <> _ = message}, req, state) do
    decoded_message = Jason.decode!(message)
    module_path = decoded_message["module_path"]

    docs = Code.fetch_docs(module_path)

    module_name =
      Path.basename(module_path, ".beam")
      |> Retriever.take_prefix("Elixir.")

    normalized_docs = Retriever.normalize_docs(module_name, docs)

    {:reply, {:text, Jason.encode!(normalized_docs)}, req, state}
  end

  def websocket_handle({:text, "{\"cmd_id\"" <> _ = message}, req, state) do
    %{
      "cmd_id" => cmd_id,
      "json_data" => %{"module_name" => module, "function" => func, "args" => args}
    } = Jason.decode!(message)

    try do
      module = String.to_atom("Elixir." <> module)
      func = String.to_atom(func)

      args = Enum.map(args, &Retriever.parse_arg(&1))

      result =
        apply(module, func, args)
        |> inspect(pretty: true)
        |> Retriever.prepend_call(module, func, args)
        |> Makeup.highlight_inner_html(lexer: "elixir")
        |> String.replace("\n", "</span><br/><span>")

      {:reply, {:text, %{"cmd_id" => cmd_id, "result" => result} |> Jason.encode!()}, req, state}
    rescue
      e ->
        result =
          inspect(e, pretty: true)
          |> Makeup.highlight_inner_html(lexer: "elixir")
          |> String.replace("\n", "</span><br/><span>")

        {:reply, {:text, %{"cmd_id" => cmd_id, "result" => result} |> Jason.encode!()}, req,
         state}
    end
  end

  def websocket_handle({:text, message}, req, state) do
    {:reply, {:text, message}, req, state}
  end

  def websocket_handle(_data, req, state) do
    {:ok, req, state}
  end

  def websocket_info({:text, %{modules: modules, project_name: project_name}}, req, state) do
    {:ok, message} = %{modules: modules, project_name: project_name} |> Jason.encode()
    {:reply, {:text, message}, req, state}
  end

  def websocket_info({:timeout, _ref, message}, req, state) do
    {:reply, {:text, message}, req, state}
  end

  def websocket_info({:broadcast, message}, req, state) do
    {:reply, {:text, message}, req, state}
  end

  def websocket_info(_, state) do
    {:ok, state}
  end
end
