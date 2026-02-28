defmodule Ex338Web.CanonicalDomainTest do
  use Ex338Web.ConnCase

  import Plug.Test

  alias Ex338Web.CanonicalDomain

  @opts CanonicalDomain.init([])

  test "redirects to root domain when host is platform domain" do
    conn = conn(:get, "https://ex338.onrender.com/foo?bar=10")

    conn = CanonicalDomain.call(conn, @opts)

    assert redirected_to(conn, 301) =~ "https://localhost/foo?bar=10"
  end
end
