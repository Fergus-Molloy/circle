defmodule Circle.Accounts.UserFollowers do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "user_followers" do
    field :user_id, :binary_id
    field :follows_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :follows_id])
    |> unique_constraint([:user_id, :follows_id])
  end
end
