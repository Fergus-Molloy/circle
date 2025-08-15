defmodule Mix.Tasks.Version do
  @moduledoc "Prints the project name and version"

  use Mix.Task

  @impl Mix.Task
  def run(_) do
    prj = Circle.MixProject.project()
    name = Keyword.get(prj, :app)
    version = Keyword.get(prj, :version)
    Mix.shell().info("App " <> to_string(name) <> "\nVersion: " <> version)
  end
end
