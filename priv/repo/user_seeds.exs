Ex338.Repo.delete_all(Ex338.Accounts.User)

%Ex338.Accounts.User{}
|> Ex338.Accounts.User.changeset(%{
  name: "Test Admin",
  email: "testadmin@example.com",
  password: "password",
  confirm_password: "password",
  admin: true
})
|> Ex338.Repo.insert!()

%Ex338.Accounts.User{}
|> Ex338.Accounts.User.changeset(%{
  name: "Test User",
  email: "testuser@example.com",
  password: "password",
  confirm_password: "password",
  admin: false
})
|> Ex338.Repo.insert!()
