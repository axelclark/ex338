defmodule Ex338Web.Pow.RedisCacheTest do
  use ExUnit.Case

  alias Ex338Web.Pow.RedisCache

  doctest Ex338Web.Pow.RedisCache

  @default_config [namespace: "test", ttl: :timer.hours(1)]

  setup do
    Redix.command!(:redix, ["FLUSHALL"])

    :ok
  end

  test "can put, get and delete records" do
    assert RedisCache.get(@default_config, "key") == :not_found

    RedisCache.put(@default_config, {"key", "value"})
    :timer.sleep(100)
    assert RedisCache.get(@default_config, "key") == "value"

    RedisCache.delete(@default_config, "key")
    :timer.sleep(100)
    assert RedisCache.get(@default_config, "key") == :not_found
  end

  test "can put multiple records at once" do
    RedisCache.put(@default_config, [{"key1", "1"}, {"key2", "2"}])
    :timer.sleep(100)
    assert RedisCache.get(@default_config, "key1") == "1"
    assert RedisCache.get(@default_config, "key2") == "2"
  end

  test "can match fetch all" do
    assert RedisCache.all(@default_config, :_) == []

    for number <- 1..11, do: RedisCache.put(@default_config, {"key#{number}", "value"})
    :timer.sleep(100)
    items = RedisCache.all(@default_config, :_)

    assert Enum.find(items, fn {key, "value"} -> key == "key1" end)
    assert Enum.find(items, fn {key, "value"} -> key == "key2" end)
    assert length(items) == 11

    RedisCache.put(@default_config, {["namespace", "key"], "value"})
    :timer.sleep(100)

    assert RedisCache.all(@default_config, ["namespace", :_]) == [{["namespace", "key"], "value"}]
  end

  test "records auto purge" do
    config = Keyword.put(@default_config, :ttl, 100)

    RedisCache.put(config, {"key", "value"})
    RedisCache.put(config, [{"key1", "1"}, {"key2", "2"}])
    :timer.sleep(50)
    assert RedisCache.get(config, "key") == "value"
    assert RedisCache.get(config, "key1") == "1"
    assert RedisCache.get(config, "key2") == "2"
    :timer.sleep(100)
    assert RedisCache.get(config, "key") == :not_found
    assert RedisCache.get(config, "key1") == :not_found
    assert RedisCache.get(config, "key2") == :not_found
  end
end
