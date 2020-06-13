Ex338.Repo.delete_all(Ex338.Accounts.User)

Ex338.Accounts.User.changeset(%Ex338.Accounts.User{}, %{
  name: "Test Admin",
  email: "testadmin@example.com",
  password: "secret",
  confirm_password: "secret",
  admin: true
})
|> Ex338.Repo.insert!()

Ex338.Accounts.User.changeset(%Ex338.Accounts.User{}, %{
  name: "Test User",
  email: "testuser@example.com",
  password: "secret",
  confirm_password: "secret",
  admin: false
})
|> Ex338.Repo.insert!()
