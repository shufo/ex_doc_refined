defmodule ExDocRefined do
  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    standalone? = Application.get_env(:ex_doc_refined, :standalone, true)

    children =
      if standalone? do
        [
          worker(ExDocRefined.Server, [[port: Application.get_env(:ex_doc_refined, :port, 5600)]])
        ]
      else
        []
      end

    opts = [strategy: :one_for_one, name: ExDocRefined.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
