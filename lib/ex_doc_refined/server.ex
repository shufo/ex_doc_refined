defmodule ExDocRefined.Server do
  use Supervisor
  require Logger

  def init(opts) do
    {:ok, opts}
  end

  def start_link(opts) do
    cowboy_version = Application.spec(:cowboy) |> cowboy_version()
    dispatch = dispatch(cowboy_version, opts)
    {:ok, pid} = start_cowboy(cowboy_version, dispatch, opts)
    Logger.info("ExDoc Refined started listening on http://localhost:#{opts[:port]}")
    {:ok, pid}
  end

  def start_link() do
    cowboy_version = Application.spec(:cowboy) |> cowboy_version()
    dispatch = dispatch(cowboy_version, [])
    {:ok, pid} = start_cowboy(cowboy_version, dispatch, [])

    Logger.info("ExDoc Refined started listening on http://localhost:5600")
    {:ok, pid}
  end

  def stop(_state) do
    :ok
  end

  # Helpers

  defp dispatch("v1" = _version, _opts) do
    :cowboy_router.compile([
      {:_,
       [
         {'/[...]/websocket', ExDocRefined.V1WebSocketHandler, []},
         {'/websocket', ExDocRefined.V1WebSocketHandler, []},
         {"/", :cowboy_static, {:priv_file, :ex_doc_refined, "index.html"}},
         {"/[...]/_nuxt/[...]", :cowboy_static, {:priv_dir, :ex_doc_refined, "_nuxt"}},
         {"/_nuxt/[...]", :cowboy_static, {:priv_dir, :ex_doc_refined, "_nuxt"}},
         {"/[...]", :cowboy_static, {:priv_file, :ex_doc_refined, "index.html"}}
       ]}
    ])
  end

  defp dispatch("v2" = _version, _opts) do
    :cowboy_router.compile([
      {:_,
       [
         {'/[...]/websocket', ExDocRefined.WebSocketHandler, []},
         {'/websocket', ExDocRefined.WebSocketHandler, []},
         {"/", :cowboy_static, {:priv_file, :ex_doc_refined, "index.html"}},
         {"/[...]/_nuxt/[...]", :cowboy_static, {:priv_dir, :ex_doc_refined, "_nuxt"}},
         {"/_nuxt/[...]", :cowboy_static, {:priv_dir, :ex_doc_refined, "_nuxt"}},
         {"/[...]", :cowboy_static, {:priv_file, :ex_doc_refined, "index.html"}}
       ]}
    ])
  end

  defp start_cowboy("v1" = _version, dispatch, opts) do
    port = Keyword.get(opts, :port, 5600)

    :cowboy.start_http(:ex_doc_refined_http_listener, 100, [{:port, port}], [
      {:env, [{:dispatch, dispatch}]}
    ])
  end

  defp start_cowboy("v2" = _version, dispatch, opts) do
    port = Keyword.get(opts, :port, 5600)

    :cowboy.start_clear(:ex_doc_refined_http_listener, [{:port, port}], %{
      env: %{dispatch: dispatch}
    })
  end

  defp cowboy_version(spec) do
    case Version.compare("2.0.0", spec[:vsn] |> to_string) do
      :gt -> "v1"
      _ -> "v2"
    end
  end
end
