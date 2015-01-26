defmodule Pool.Util do
  def fix_ip(opts) do
    {opts, ip} = case opts[:ip] do
      ip when ip |> is_tuple ->
        {opts, ip}
      ip when ip |> is_list ->
        {:ok, ip_tuple} = :inet_parse.address(ip)
        {[{:ip, ip_tuple} | opts |> Keyword.delete(:ip)], ip_tuple}
      :any ->
        {opts, :any}
      nil ->
        {[{:ip, :any} | opts], :any}
    end

    case ip do
      {_, _, _, _} ->
        [:inet | opts]
      {_, _, _, _, _, _, _, _} ->
        [:inet6 | opts]
      :any ->
        if ip_v6_supported? do
          [:inet | [:inet6 | opts]]
        else
          opts
        end
    end
  end

  defp ip_v6_supported? do
    case :inet.getaddr('localhost', :inet6) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end
end
