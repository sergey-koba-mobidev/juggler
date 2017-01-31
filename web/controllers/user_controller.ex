defmodule Juggler.UserController do
  use Juggler.Web, :controller
  alias Juggler.User
  import Comeonin.Bcrypt

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, Map.merge(user_params, %{"encrypted_password" => hashpwsalt(user_params["password"])}))

    case Repo.insert(changeset) do
      {:ok, _project} ->
        conn
        |> put_flash(:info, "Thank you for signup")
        |> redirect(to: project_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
