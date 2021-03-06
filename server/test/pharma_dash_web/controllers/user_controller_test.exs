defmodule PharmaDashWeb.UserControllerTest do
  use PharmaDashWeb.ConnCase

  alias PharmaDash.Auth
  alias PharmaDash.Auth.User
  alias Plug.Test

  alias PharmaDash.Entities
  alias PharmaDash.Entities.Pharmacy

  @create_pharmacy_attrs %{
    city: "some city",
    name: "some name",
    stateAbr: "some stateAbr",
    street: "some street",
    zipcode: "some zipcode"
  }
  @create_user_attrs %{
    email: "some email",
    is_active: true,
    name: "some name",
    password: "some password"
  }
  @update_attrs %{
    email: "some updated email",
    is_active: false,
    name: "some updated name",
    password: "some updated password"
  }
  @invalid_attrs %{email: nil, is_active: nil, name: nil, password: nil}
  @current_user_attrs %{
    email: "some current user email",
    is_active: true,
    password: "some current user password",
    name: "some current user name"
  }

  def fixture(:user) do
    {:ok, user} = Auth.create_user(@create_user_attrs)
    user
  end

  def fixture(:pharmacy) do
    {:ok, pharmacy} = Entities.create_pharmacy(@create_pharmacy_attrs)
    pharmacy
  end

  def fixture(:current_user) do
    {:ok, current_user} = Auth.create_user(@current_user_attrs)
    current_user
  end

  setup %{conn: conn} do
    {:ok, conn: conn, current_user: current_user} = setup_current_user(conn)
    {:ok, conn: put_req_header(conn, "accept", "application/json"), current_user: current_user}
  end

  describe "index" do
    test "lists all users", %{conn: conn, current_user: current_user} do
      # Get function makes a get request to UserController
      conn = get(conn, Routes.user_path(conn, :index))

      assert json_response(conn, 200)["data"] == [
               %{
                 "id" => current_user.id,
                 "email" => current_user.email,
                 "is_active" => current_user.is_active,
                 "name" => current_user.name
               }
             ]
    end
  end

  describe "create user associated with a pharmacy" do
    setup [:create_pharmacy]

    test "renders user when data is valid", %{conn: conn, pharmacy: %Pharmacy{id: id}} do
      conn =
        post(conn, Routes.user_path(conn, :create_pharmacy_user, id), user: @create_user_attrs)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => id,
               "email" => "some email",
               "is_active" => true,
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, pharmacy: %Pharmacy{id: id}} do
      conn = post(conn, Routes.user_path(conn, :create_pharmacy_user, id), user: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => id,
               "email" => "some updated email",
               "is_active" => false,
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "sign_in user" do
    test "renders user when user credentails are good", %{conn: conn, current_user: current_user} do
      conn =
        post(
          conn,
          Routes.user_path(conn, :sign_in),
          %{
            user: %{
              email: current_user.email,
              password: @current_user_attrs.password
            }
          }
        )

      assert json_response(conn, 200)["data"] == %{
               "id" => current_user.id,
               "email" => current_user.email,
               "name" => current_user.name,
               "is_courier" => false,
               "is_pharmacy" => false,
               "pharmacy_id" => nil,
               "courier_id" => nil
             }
    end

    test "renders errors when user credentials are bad", %{conn: conn} do
      conn =
        post(conn, Routes.user_path(conn, :sign_in), %{
          user: %{email: "nonexistent email", password: ""}
        })

      assert json_response(conn, 401)["errors"] == %{"detail" => "Wrong email or password"}
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end

  defp create_pharmacy(_) do
    pharmacy = fixture(:pharmacy)
    {:ok, pharmacy: pharmacy}
  end

  defp setup_current_user(conn) do
    current_user = fixture(:current_user)

    {:ok,
     conn: Test.init_test_session(conn, current_user_id: current_user.id),
     current_user: current_user}
  end
end
