defmodule Ex338Web.UserViewTest do
  use Ex338Web.ConnCase, async: true

  alias Ex338Web.UserView

  alias Ex338.User

  describe "user_profile_image/1" do
    test "returns an image tag with the gravatar link" do
      user = %User{email: "user@example.com"}

      result = UserView.user_profile_image(user)

      assert result ==
               {:safe,
                [
                  60,
                  "img",
                  [
                    [32, "border", 61, 34, "1", 34],
                    [
                      32,
                      "src",
                      61,
                      34,
                      [
                        [
                          [],
                          "https://secure.gravatar.com/avatar/b58996c504c5638798eb6b511e6f49af?s=256"
                          | "&amp;"
                        ]
                        | "d=blank"
                      ],
                      34
                    ]
                  ],
                  62
                ]}
    end
  end
end
