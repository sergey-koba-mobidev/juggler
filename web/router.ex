defmodule Juggler.Router do
  use Juggler.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Juggler do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/projects", ProjectController do
      resources "/builds", BuildController, only: [:create, :show]
    end
    resources "/users", UserController, except: [:index, :delete]
    get "/login", UserController, :login
    post "/authenticate", UserController, :authenticate
  end

  # Other scopes may use custom stacks.
  # scope "/api", Juggler do
  #   pipe_through :api
  # end
end
