Ex338.Repo.delete_all Ex338.User

Ex338.User.changeset(%Ex338.User{}, %{name: "Test Admin", email: "testadmin@example.com", password: "secret", password_confirmation: "secret", admin: true})
|> Ex338.Repo.insert!

Ex338.User.changeset(%Ex338.User{}, %{name: "Test User", email: "testuser@example.com", password: "secret", password_confirmation: "secret", admin: false})
|> Ex338.Repo.insert!
