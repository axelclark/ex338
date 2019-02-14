defmodule Ex338Web.PowRedisCache do
  @moduledoc false
  @behaviour Pow.Store.Base

  alias Pow.Config

  @redix_instance_name :redix

  def name(), do: @redix_instance_name

  def put(config, key, value) do
    key = redis_key(config, key)
    ttl = Config.get(config, :ttl)
    value = :erlang.term_to_binary(value)
    command = put_command(key, value, ttl)

    Redix.noreply_command(@redix_instance_name, command)
  end

  defp put_command(key, value, ttl) when is_integer(ttl) and ttl > 0,
    do: ["SET", key, value, "PX", ttl]

  defp put_command(key, value, _ttl), do: ["SET", key, value]

  def delete(config, key) do
    key = redis_key(config, key)

    Redix.noreply_command(@redix_instance_name, ["DEL", key])
  end

  def get(config, key) do
    key = redis_key(config, key)

    case Redix.command(@redix_instance_name, ["GET", key]) do
      {:ok, nil} -> :not_found
      {:ok, value} -> :erlang.binary_to_term(value)
    end
  end

  def keys(config) do
    namespace = redis_key(config, "")
    length = String.length(namespace)

    {:ok, values} = Redix.command(@redix_instance_name, ["KEYS", "#{namespace}*"])

    Enum.map(values, &String.slice(&1, length..-1))
  end

  defp redis_key(config, key) do
    namespace = Config.get(config, :namespace, "cache")

    "#{namespace}:#{key}"
  end
end
