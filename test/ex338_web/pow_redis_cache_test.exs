defmodule Ex338Web.PowRedisCacheTest do
  use ExUnit.Case
  doctest Ex338Web.PowRedisCache

  alias Ex338Web.PowRedisCache

  @default_config [namespace: "test", ttl: :timer.hours(1)]

  test "can put, get and delete records" do
    assert PowRedisCache.get(@default_config, "key") == :not_found

    PowRedisCache.put(@default_config, "key", "value")
    :timer.sleep(100)
    assert PowRedisCache.get(@default_config, "key") == "value"

    PowRedisCache.delete(@default_config, "key")
    :timer.sleep(100)
    assert PowRedisCache.get(@default_config, "key") == :not_found
  end

  test "fetch keys" do
    PowRedisCache.put(@default_config, "key1", "value")
    PowRedisCache.put(@default_config, "key2", "value")
    :timer.sleep(100)

    assert Enum.sort(PowRedisCache.keys(@default_config)) == ["key1", "key2"]
  end

  test "records auto purge" do
    config = Keyword.put(@default_config, :ttl, 100)

    PowRedisCache.put(config, "key", "value")
    :timer.sleep(50)
    assert PowRedisCache.get(config, "key") == "value"
    :timer.sleep(100)
    assert PowRedisCache.get(config, "key") == :not_found
  end
end
