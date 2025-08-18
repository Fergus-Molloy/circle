# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Circle.Repo.insert!(%Circle.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Circle.Repo
alias Circle.Accounts.User
alias Ecto.Changeset

u1 = Repo.insert!(Changeset.change(%User{email: "asdf@asdf.com", username: "asfd"}))
u2 = Repo.insert!(Changeset.change(%User{email: "asdf@molloy.com", username: "asfdasdf"}))
u3 = Repo.insert!(%User{email: "fergus@molloy.xyz", username: "fergus", is_admin: true})
Repo.insert!(Changeset.change(%Circle.Accounts.UserFollowers{user_id: u1.id, follows_id: u2.id}))
Repo.insert!(Changeset.change(%Circle.Accounts.UserFollowers{user_id: u2.id, follows_id: u1.id}))
