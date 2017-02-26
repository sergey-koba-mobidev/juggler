defmodule Juggler.Router do
  use Juggler.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :fetch_flash
  end

  scope "/", Juggler do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/projects", ProjectController do
      resources "/builds", BuildController, only: [:create, :show, :index] do
        get "/restart", BuildController, :restart
      end
      resources "/deploys", DeployController, only: [:create, :show, :index] do
        get "/restart", DeployController, :restart
      end
      resources "/servers", ServerController
      get  "/github", GithubController, :setup
      get  "/github/callback", GithubController, :callback
      get  "/github/select_repo", GithubController, :select_repo
      post "/github/set_repo", GithubController, :set_repo
      delete "/github/unlink", GithubController, :unlink
    end
    resources "/users", UserController, except: [:index, :delete]
    get  "/login", UserController, :login
    get  "/logout", UserController, :logout
    post "/authenticate", UserController, :authenticate
    get  "/forgot_password", UserController, :forgot_password
    post "/reset_password", UserController, :reset_password
    get  "/new_password", UserController, :new_password
    post "/set_password", UserController, :set_password
  end

  scope "/api", Juggler do
    pipe_through :api
    resources "/projects", ProjectController do
      resources "/ssh_keys", SSHKeysController
      post  "/github/webhook", GithubController, :webhook
    end
  end
end
