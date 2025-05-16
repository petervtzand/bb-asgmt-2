defmodule AppWeb.PageController do
  use AppWeb, :controller
  require IEx

  import Ecto.Query, only: [from: 2]

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end

  @doc """
  Create a random user, so we can generate test data

  """
  def create_random_user() do
    # Define some random first and last names
    random_first_names = ["Peter", "Perry", "Paul", "Pim", "Paco"]
    random_last_names = ["Zand", "Hofman", "Bakker", "Pot", "Bak", "Hal"]

    # Create a map with random values
    random_user_map = %{
      first_name: Enum.random(random_first_names),
      last_name: Enum.random(random_last_names),
      number_of_bikes: Enum.random(0..100)
    }

    # create a changeset and insert into db
    changeset = App.User.changeset(%App.User{}, random_user_map)
    App.Repo.insert(changeset)
  end

  @doc """
  Create random users, to generate test data

  """
  def create_users() do
    Enum.each(0..20, fn _x -> create_random_user() end)
  end

  @doc """
  Transforms a list of string into a list of atoms

  ## Parameters
  - string_list: A list of strings

  Returns a list of atoms

  """
  def transform_string_list_into_atom_list(string_list) do
    %{:select => string_list}
    |> Map.get(:select)
    |> Enum.map(fn x -> String.to_atom(x) end)
  end

  @doc """
  Runs a redis command

  Returns the result of the command

  ## Parameters
  - command_to_run: array of commands, e.g. ['PING']

  """
  def run_redis_command(command_to_run) do
    Redix.start_link("redis://redis:6379/0", name: :redix)
    Redix.command(:redix, command_to_run)
  end

  @doc """
  Route for returning all table names that are found in Redis

  Returns a json response with key = 'table_names', value = list of table names

  """
  def return_all_table_names(conn, _params) do
    # get the column names from redis
    {:ok, table_names} = run_redis_command(["LRANGE", "tables", 0, -1])

    json(conn, %{:table_names => table_names})
  end

  @doc """
  Route for returning all instances of a given table name

  ## Parameters:application
  - params.model_name: string of the name of the model

  Returns a json response with key = 'table_name', value = list serialized instances

  """
  def return_model_route(conn, params) do
    # get model_name from params
    model_name = params["model_name"]

    query_params = Plug.Conn.fetch_query_params(conn).query_params

    # get the actual model if it exists
    model = get_model_by_table_name(model_name)

    # get the column names from redis
    {:ok, column_names} = run_redis_command(["LRANGE", "columns:#{model_name}", 0, -1])

    instances =
      from(
        instance in model,
        select: map(instance, ^transform_string_list_into_atom_list(column_names))
      )
      |> App.Repo.all()

    json(conn, %{model_name => instances})
  end

  @doc """
  Return an Ecto model with given table name

  ## Parameters:application
  - model_name: string of the name of the model

  Returns an Ecto model

  """
  def get_model_by_table_name(model_name) do
    if(model_name == "users") do
      App.User
    else
      raise "No model found"
    end
  end
end
