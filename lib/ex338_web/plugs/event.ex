defmodule Ex338Web.RequestEvent do
  @moduledoc """
  Sends a mixpanel "request" event
  """

  def init(_), do: nil

  def call(conn, _params) do
    Task.start(fn -> send_data(conn) end)
    conn
  end

  ## Helpers

  defp send_data(conn) do
    headers = Map.new(conn.req_headers)
    ip = conn.remote_ip

    user_id = extract_user_id(conn.assigns)

    properties = %{
      remote_ip: ip |> Tuple.to_list() |> Enum.join("."),
      req_headers: headers,
      host: conn.host,
      method: conn.method,
      request_path: conn.request_path,
      port: conn.port,
      query_string: conn.query_string,
      referer: headers["referer"],
      user_agent: headers["user-agent"],
      user_id: user_id
    }

    Ex338.Mixpanel.track(
      "Request",
      properties,
      distinct_id: user_id,
      ip: ip
    )
  end

  defp extract_user_id(%{current_user: %{id: id}}), do: Integer.to_string(id)
  defp extract_user_id(_assigns), do: nil
end
