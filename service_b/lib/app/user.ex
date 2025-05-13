defmodule App.User do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:first_name, :last_name, :number_of_bikes]}
  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :number_of_bikes, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :number_of_bikes])
    |> validate_required([:first_name, :last_name, :number_of_bikes])
  end
end
