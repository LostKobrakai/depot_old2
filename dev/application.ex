defmodule Depot.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      Depot.LocalFilesystem
    ]

    opts = [strategy: :one_for_one, name: Depot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
