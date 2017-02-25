defmodule Juggler.Deploy.Operations.StartDeploy do
  def call(deploy) do
    Verk.enqueue(%Verk.Job{queue: String.to_atom("project_" <> Integer.to_string(deploy.project_id)), class: "ExecDeployJob", args: [deploy.id], max_retry_count: 0})
  end
end
