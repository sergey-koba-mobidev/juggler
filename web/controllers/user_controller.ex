defmodule Juggler.UserController do
  use Juggler.Web, :controller
  alias Juggler.User
  import Comeonin.Bcrypt
  import Juggler.UserOperations

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

  def edit(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)
    if user_params["password"] != "", do: user_params = Map.merge(user_params, %{"encrypted_password" => hashpwsalt(user_params["password"])})
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "Profile updated successfully.")
        |> redirect(to: user_path(conn, :edit, user))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def login(conn, _params) do
    render(conn, "login.html")
  end

  def logout(conn, _params) do
    result = success(conn)
             ~>> fn conn -> destroy_session(conn) end

   if success?(result) do
     conn = unwrap!(result)
     conn
     |> put_flash(:info, "You are logged out")
     |> redirect(to: project_path(conn, :index))
   else
     conn
     |> put_flash(:error, result.error)
     |> redirect(to: project_path(conn, :index))
   end
  end

  def authenticate(conn, %{"login" => %{"email" => email, "password" => password}}) do
    user = nil
    result = success(user)
             ~>> fn _user -> validate_user_exists(email) end
             ~>> fn user -> validate_password(user, password) end
             ~>> fn user -> create_session(conn, user) end

    if success?(result) do
     conn = unwrap!(result)
     conn
     |> put_flash(:info, "Welcome to Juggler")
     |> redirect(to: project_path(conn, :index))
    else
     conn
     |> put_flash(:error, result.error)
     |> render("login.html")
    end
  end

  def forgot_password(conn, _params) do
    render conn, "forgot_password.html"
  end

  def reset_password(conn, %{"reset_password" => %{"email" => email}}) do
    # do smth
  end
end
