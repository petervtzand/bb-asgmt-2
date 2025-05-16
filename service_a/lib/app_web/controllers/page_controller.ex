defmodule AppWeb.PageController do
  use AppWeb, :controller
  require IEx

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end

  @doc """
  Reads a file with given file path en returns the data found in file

  Returns a map

  ## Parameters
  - app_file_path: The path within the application

  """
  def get_data_from_file(app_file_path) do
    path = Path.join(File.cwd!(), app_file_path)
    YamlElixir.read_from_file(path)
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
  Saves the found table info to redis

  ## Parameters
  - tables_info: mapping of the table info

  """
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

  @doc """
  Route for reading the datastructure file and saving to redis

  Returns a json response with key = 'tables' and value = list of table names

  """
  @spec my_read_file_route(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def my_read_file_route(conn, _params) do
    # read file and extra 'tables' data
    {:ok, yaml_data} = get_data_from_file("assets/data-structure-info.yml")
    tables_info = yaml_data["tables"]

    save_tables_info_to_redis(tables_info)

    {:ok, table_names} = run_redis_command(["LRANGE", "tables", 0, -1])

    json(conn, %{:tables => table_names})
  end
end
