defmodule Juggler do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Juggler.Repo, []),
      # Start the endpoint when the application starts
      supervisor(Juggler.Endpoint, []),
      # Verk job supervisor
      supervisor(Verk.Supervisor, []),
      # Start your own worker by calling: Juggler.Worker.start_link(arg1, arg2, arg3)
      # worker(Juggler.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Juggler.Supervisor]
    res = Supervisor.start_link(children, opts)

    for project <- Juggler.Repo.all(Juggler.Project) do
      Verk.add_queue(String.to_atom("project_" <> Integer.to_string(project.id)), 1)
    end

    res
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Juggler.Endpoint.config_change(changed, removed)
    :ok
  end
end
