defmodule ExDocRefined.WebSocketHandler do
  @moduledoc """
  Websocket Handler for Cowboy 2
  """
  alias ExDocRefined.Retriever

  def init(req, state) do
    opts = %{idle_timeout: 60000}

    {:cowboy_websocket, req, state, opts}
  end

  def websocket_init(state) do
    message =
      %{modules: Retriever.project_modules(), project_name: Retriever.project_name()}
      |> Jason.encode!()

    send(self(), {:text, message})

    {:ok, state}
  end

  def terminate(_reason, _req, _state) do
    :ok
  end

  def websocket_handle({:text, "{\"module_path\"" <> _ = message}, state) do
    decoded_message = Jason.decode!(message)
    module_path = decoded_message["module_path"]

    docs = Code.fetch_docs(module_path)

    module_name =
      Path.basename(module_path, ".beam")
      |> Retriever.take_prefix("Elixir.")

    normalized_docs = Retriever.normalize_docs(module_name, docs)

    {:reply, {:text, Jason.encode!(normalized_docs)}, state}
  end

  def websocket_handle({:text, "{\"cmd_id\"" <> _ = message}, state) do
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

      {:reply, {:text, %{"cmd_id" => cmd_id, "result" => result} |> Jason.encode!()}, state}
    rescue
      e ->
        result =
          inspect(e, pretty: true)
          |> Makeup.highlight_inner_html(lexer: "elixir")
          |> String.replace("\n", "</span><br/><span>")

        {:reply, {:text, %{"cmd_id" => cmd_id, "result" => result} |> Jason.encode!()}, state}
    end
  end

  def websocket_handle({:text, message}, state) do
    {:reply, {:text, message}, state}
  end

  def websocket_handle(_data, state) do
    {:ok, state}
  end

  def websocket_info({:text, message}, state) do
    {:reply, {:text, message}, state}
  end

  def websocket_info({:modules, modules}, state) do
    {:ok, message} = %{modules: modules} |> Jason.encode()
    {:reply, {:text, message}, state}
  end

  def websocket_info({:timeout, _ref, message}, state) do
    {:reply, {:text, message}, state}
  end

  def websocket_info({:broadcast, message}, state) do
    {:reply, {:text, message}, state}
  end

  def websocket_info(_, state) do
    {:ok, state}
  end
end
