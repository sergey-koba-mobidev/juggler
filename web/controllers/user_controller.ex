defmodule Juggler.UserController do
  use Juggler.Web, :controller
  alias Juggler.User
  alias Juggler.User.Operations.{ValidateUserExists, ValidatePassword,
    CreateSession, DestroySession, EncryptPasswordParam, Create, Update,
    SetResetPasswordToken, SendResetPasswordEmail, GetByResetPasswordToken,
    SetNewPassword, SubscribeToPlan, CreateQueue}

  plug Juggler.Plugs.Authenticated when action in [:update, :edit, :logout, :search]
  plug Juggler.Plugs.NotAuthenticated when action in [:new, :create, :login, :authenticate, :forgot_password, :reset_password, :new_password, :set_password]

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    result = success(user_params)
             ~>> fn user_params -> EncryptPasswordParam.call(user_params) end
             ~>> fn user_params -> Create.call(user_params) end
             ~>> fn user -> SubscribeToPlan.call(user, "free") end
             ~>> fn user -> CreateQueue.call(user) end

    if success?(result) do
      conn
      |> put_flash(:info, "Thank you for signup")
      |> redirect(to: project_path(conn, :index))
    else
      changeset = result.error
      render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    result = success(user_params)
             ~>> fn user_params -> EncryptPasswordParam.call(user_params) end
             ~>> fn user_params -> Update.call(id, user_params) end

    if success?(result) do
      user = unwrap!(result)
      conn
      |> put_flash(:info, "Profile updated successfully.")
      |> redirect(to: user_path(conn, :edit, user))
    else
      changeset = result.error
      render(conn, "edit.html", changeset: changeset)
    end
  end

  def login(conn, _params) do
    render(conn, "login.html")
  end

  def logout(conn, _params) do
    result = DestroySession.call(conn)

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
    result = success(email)
             ~>> fn email -> ValidateUserExists.call(email) end
             ~>> fn user -> ValidatePassword.call(user, password) end
             ~>> fn user -> CreateSession.call(conn, user) end

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
    result = success(email)
             ~>> fn email -> ValidateUserExists.call(email) end
             ~>> fn user -> SetResetPasswordToken.call(user) end
             ~>> fn user -> SendResetPasswordEmail.call(conn, user) end

    if success?(result) do
     conn
     |> put_flash(:info, "Reset password email is sent to " <> email)
     |> redirect(to: user_path(conn, :login))
    else
     conn
     |> put_flash(:error, result.error)
     |> redirect(to: user_path(conn, :forgot_password))
    end
  end

  def new_password(conn, %{"email" => email, "token" => token}) do
    result = GetByResetPasswordToken.call(email, token)

    if success?(result) do
     render conn, "new_password.html", user: unwrap!(result)
    else
     conn
     |> put_flash(:error, result.error)
     |> redirect(to: user_path(conn, :forgot_password))
    end
  end

  def set_password(conn, %{"email" => email, "token" => token, "set_password" => user_params}) do
    user_params = unwrap!(EncryptPasswordParam.call(user_params))
    result = success(nil)
             ~>> fn _    -> GetByResetPasswordToken.call(email, token) end
             ~>> fn user -> SetNewPassword.call(user, user_params) end

    if success?(result) do
     conn
     |> put_flash(:info, "Password for " <> email <> " was successfully changed.")
     |> redirect(to: user_path(conn, :login))
    else
     conn
     |> put_flash(:error, result.error)
     |> redirect(to: user_path(conn, :forgot_password))
    end
  end

  def search(conn, %{"q" => email}) do
    users = from(u in User,
      where: like(u.email, ^"%#{email}%"),
      limit: 10,
      select: map(u, [:id, :name, :email])) |> Repo.all
    render conn, "index.json", users: users
  end
end
