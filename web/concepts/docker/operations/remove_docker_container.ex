defmodule Juggler.Docker.Operations.RemoveDockerContainer do
  alias Porcelain.Result
  require Logger
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]

  def call(container_id) do
    %Result{out: output, status: status} = Porcelain.shell("docker inspect -f {{.State.Running}} " <> container_id, err: :out)
    if status == 0 do
      %Result{out: output, status: status} = Porcelain.shell("docker rm -f " <> container_id, err: :out)
      case status do
        0 ->
          Logger.info " ---> Removed docker cont " <> container_id
          success(container_id)
        _ -> error("Failed to remove docker cont: " <> output)
      end
    else
      error("No docker cont found " <> container_id)
    end
  end
end
