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
  end

  scope "/", Juggler do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/projects", ProjectController do
      resources "/builds", BuildController, only: [:create, :show]
      get  "/github", GithubController, :setup
      get  "/github/callback", GithubController, :callback
      get  "/github/select_project", GithubController, :select_project
      post "/github/set_project", GithubController, :set_project
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

  # Other scopes may use custom stacks.
  # scope "/api", Juggler do
  #   pipe_through :api
  # end
end
