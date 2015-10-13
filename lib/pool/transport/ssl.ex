defmodule Pool.Transport.SSL do
  @moduledoc """
  Implements the `Pool.Socket` protocol SSL/TLS connections.
  """
  defstruct socket: nil, options: []
end
