Ex338.Repo.delete_all Ex338.User

Ex338.User.changeset(%Ex338.User{}, %{name: "Test User", email: "testuser@example.com", password: "secret", password_confirmation: "secret"})
|> Ex338.Repo.insert!
