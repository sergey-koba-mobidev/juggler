defmodule Juggler.Build.Operations.BuildDockerImage do
  alias Porcelain.Result
  alias Juggler.Repo
  alias Juggler.Project
  alias Juggler.Build
  require Logger
  require File
  use Monad.Operators
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]

  def call(build) do
    project = Project |> Repo.get!(build.project_id)
    case project.dockerfile do
      ""   -> success(build)
      nil  -> success(build)
      text ->
        image_tag = "juggler:project_" <> Integer.to_string(build.project_id)
        dockerfile_name = "dfproject_" <> Integer.to_string(build.project_id)
        result = success(nil)
          ~>> fn _ -> write_dockerfile(dockerfile_name, text) end
          ~>> fn _ -> build_image(dockerfile_name, image_tag) end
          ~>> fn _ -> remove_dockerfile(dockerfile_name) end
          ~>> fn _ -> update_project(project, image_tag) end

        case success?(result) do
          true  -> success(build)
          false -> error(result.error)
        end
    end
  end

  def write_dockerfile(filename, text) do
    case File.open(filename, [:write, :utf8]) do
      {:ok, file} ->
        IO.puts file, text
        File.close file
        success(filename)
      {:error, reason} -> error("Failed to create Dockerfile reason:" <> reason)
    end
  end

  def remove_dockerfile(filename) do
    case File.rm(filename) do
      :ok -> success(filename)
      {:error, reason} -> error("Failed to remove Dockerfile reason:" <> reason)
    end
  end

  def build_image(filename, image_tag) do
    docker_cmd = "docker build -t " <> image_tag <> " - < " <> filename
    %Result{out: output, status: status} = Porcelain.shell(docker_cmd, err: :out)
    Logger.info "---> Building custom Dockerfile"
    Logger.info output
    case status do
      0 -> success(image_tag)
      _ -> error("Failed to build image " <> image_tag <> " cmd: " <> docker_cmd)
    end
  end

  def update_project(project, image_tag) do
    changeset = Project.changeset(project, %{:docker_image => image_tag})

    case Repo.update(changeset) do
      {:ok, project} ->
        success(project)
      {:error, _changeset} ->
        error("Error updating docker_image")
    end
  end
end
