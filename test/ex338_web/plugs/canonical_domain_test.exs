defmodule Ex338Web.CanonicalDomainTest do
  use Ex338Web.ConnCase
  use Plug.Test

  alias Ex338Web.{CanonicalDomain}

  @opts CanonicalDomain.init([])

  test "redirects to root domain when host is heroku domain" do
    conn = conn(:get, "https://the338challenge.herokuapp.com/foo?bar=10")

    conn = CanonicalDomain.call(conn, @opts)

    assert redirected_to(conn, 301) =~ "https://localhost/foo?bar=10"
  end
end
