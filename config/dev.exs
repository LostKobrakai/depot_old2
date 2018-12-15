use Mix.Config

config :depot, Depot.LocalFilesystem,
  adapter: Depot.Adapters.Local,
  root: "files"
