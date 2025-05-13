defmodule AppWeb.PageController do
  use AppWeb, :controller
  require IEx

  import Ecto.Query, only: [from: 2]

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

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

  def create_users(conn, _params) do
    Enum.each(0..20, fn _x -> create_random_user() end)
    send_resp(conn, 200, "OK")
  end

  def transform_string_list_into_atom_list(string_list) do
    %{:select => string_list}
    |> Map.get(:select)
    |> Enum.map(fn x -> String.to_atom(x) end)
  end

  def get_data_from_file(app_file_path) do
    path = Path.join(File.cwd!(), app_file_path)
    YamlElixir.read_from_file(path)
  end

  def run_redis_command(command_to_run) do
    Redix.start_link("redis://redis:6379/0", name: :redix)
    Redix.command(:redix, command_to_run)
  end

  def save_tables_info_to_redis(tables_info) do
    # delete tables var, to make sure we don't add duplicate keys
    run_redis_command(["DEL", "tables"])

    # loop over tables info, add table name to tables, and save columns for each table in "columns:<table_name>"
    for {k, v} <- tables_info do
      run_redis_command(["LPUSH", "tables", k])
      run_redis_command(["DEL", "columns:#{k}"])
      run_redis_command(["LPUSH", "columns:#{k}" | v])
    end
  end

  @spec my_read_file_route(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def my_read_file_route(conn, _params) do
    # read file and extra 'tables' data
    {:ok, yaml_data} = get_data_from_file("assets/data-structure-info.yml")
    tables_info = yaml_data["tables"]

    save_tables_info_to_redis(tables_info)

    {:ok, table_names} = run_redis_command(["LRANGE", "tables", 0, -1])

    json(conn, %{:tables => table_names})
  end

  def return_model_route(conn, params) do
    # get model_name from params
    model_name = params["model_name"]

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

  def get_model_by_table_name(model_name) do
    if(model_name == "users") do
      App.User
    else
      raise "No model found"
    end
  end
end
