defmodule AppWeb.PageController do
  use AppWeb, :controller
  require IEx

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
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
end
