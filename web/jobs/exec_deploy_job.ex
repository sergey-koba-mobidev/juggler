defmodule ExecDeployJob do
  require Logger
  alias Juggler.Deploy.Operations.ExecDeploy

  def perform(deploy_id) do
    Logger.info " ---> Started deploy " <> Integer.to_string(deploy_id)
    ExecDeploy.call(deploy_id)
    {:ok}
  end
end
