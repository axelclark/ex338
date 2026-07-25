defmodule Ex338Web.Api.V1.McpController do
  @moduledoc """
  Model Context Protocol (MCP) server over a single authenticated JSON-RPC 2.0
  endpoint (the stateless Streamable HTTP transport, request/response only).

  The request is authenticated by `Ex338Web.Plugs.ApiAuth`, so `current_user` is
  already assigned. Supported methods: `initialize`, `ping`, `tools/list`, and
  `tools/call`. Notifications (requests without an `id`) get a 202 with no body.
  Tool logic and authorization live in `Ex338Web.Api.V1.Mcp.Tools`.
  """
  use Ex338Web, :controller

  alias Ex338Web.Api.V1.ErrorJSON
  alias Ex338Web.Api.V1.Mcp.Tools

  @protocol_version "2025-06-18"

  def handle(conn, %{"_json" => batch}) when is_list(batch) do
    actor = actor(conn)
    responses = batch |> Enum.map(&dispatch(&1, actor)) |> Enum.reject(&(&1 == :notification))

    if responses == [], do: send_resp(conn, 202, ""), else: json(conn, responses)
  end

  def handle(conn, params) do
    case dispatch(params, actor(conn)) do
      :notification -> send_resp(conn, 202, "")
      response -> json(conn, response)
    end
  end

  defp actor(conn) do
    %{user: conn.assigns.current_user, api_token: conn.assigns[:current_api_token]}
  end

  defp dispatch(%{"jsonrpc" => "2.0", "method" => method} = req, actor) do
    case Map.fetch(req, "id") do
      {:ok, id} -> envelope(rpc_result(method, Map.get(req, "params", %{}), actor), id)
      :error -> :notification
    end
  end

  defp dispatch(_invalid, _actor) do
    envelope({:error, {-32_600, "Invalid Request"}}, nil)
  end

  defp rpc_result("initialize", params, _actor) do
    version = Map.get(params, "protocolVersion", @protocol_version)

    {:ok,
     %{
       protocolVersion: version,
       capabilities: %{tools: %{}},
       serverInfo: %{name: "ex338", version: "1.0.0"}
     }}
  end

  defp rpc_result("ping", _params, _actor), do: {:ok, %{}}

  defp rpc_result("tools/list", _params, _actor), do: {:ok, %{tools: Tools.list()}}

  defp rpc_result("tools/call", %{"name" => name} = params, actor) do
    name
    |> Tools.call(Map.get(params, "arguments", %{}), actor)
    |> tool_result()
  end

  defp rpc_result("tools/call", _params, _actor) do
    {:error, {-32_602, "Missing tool name"}}
  end

  defp rpc_result(_method, _params, _actor), do: {:error, {-32_601, "Method not found"}}

  # Domain outcomes surface as tool results with isError so the model can react;
  # protocol misuse surfaces as a JSON-RPC error.
  defp tool_result({:ok, data}) do
    {:ok, %{content: [%{type: "text", text: Jason.encode!(data)}], isError: false}}
  end

  defp tool_result({:error, :not_found}), do: {:ok, tool_error("Not found")}

  defp tool_result({:error, :forbidden}) do
    {:ok, tool_error("You are not authorized to perform this action")}
  end

  defp tool_result({:error, :draft_picks_locked}) do
    {:ok, tool_error("Draft picks are locked for this league")}
  end

  defp tool_result({:error, %Ecto.Changeset{} = changeset}) do
    %{errors: errors} = ErrorJSON.changeset_error(%{changeset: changeset})
    {:ok, tool_error("Validation failed: #{Jason.encode!(errors)}")}
  end

  defp tool_result({:error, {:invalid_params, message}}), do: {:error, {-32_602, message}}

  defp tool_result({:error, :unknown_tool}), do: {:error, {-32_602, "Unknown tool"}}

  defp tool_error(message) do
    %{content: [%{type: "text", text: message}], isError: true}
  end

  defp envelope({:ok, result}, id), do: %{jsonrpc: "2.0", id: id, result: result}

  defp envelope({:error, {code, message}}, id) do
    %{jsonrpc: "2.0", id: id, error: %{code: code, message: message}}
  end
end
