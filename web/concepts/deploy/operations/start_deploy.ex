defmodule Juggler.Deploy.Operations.StartDeploy do
  def call(deploy) do
    #Verk.enqueue(%Verk.Job{queue: String.to_atom("project_" <> Integer.to_string(build.project_id)), class: "ExecBuildJob", args: [build.id], max_retry_count: 0})
  end
end
