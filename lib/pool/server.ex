defmodule Pool.Server do
  @moduledoc """
  Tracks atom <-> PID relationships for listeners.
  PIDs are monitored in the `Pool.Server` process.
  """

  use GenServer

  @type ref    :: atom
  @type struct :: term

  defmodule State do
    @moduledoc false
    defstruct monitors: []
  end

  @table __MODULE__

  @doc """
  Sets a listener `pid` for a given `ref`. The `ref`
  should be an identifier for the process passed to
  `Pool.start_listener/7`.

  ## Arguments

  - `ref` - `atom` - reference for a listener process
  - `pid` - `pid` - the listener PID

  ## Returns

  `:ok`
  """
  @spec set_listener(ref, pid) :: :ok
  def set_listener(ref, pid) do
    true = GenServer.call(__MODULE__, {:set_listener, ref, pid})
    :ok
  end

  @doc """
  Gets a listener `pid` by a given `ref`. 

  ## Arguments

  - `ref` - `atom` - reference for a listener process

  ## Returns

  `pid`
  """
  @spec get_listener(ref) :: pid
  def get_listener(ref) do
    :ets.lookup_element(@table, {:listeners, ref}, 2)
  end

  @spec start_link :: {:ok, pid}
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  ## GenServer callbacks

  @doc """
  Creates a monitor reference for any listeners
  that may already exist in the ets table.
  """
  @spec init(Keyword.t) :: {:ok, struct}
  def init(_opts \\ []) do
    monitors = for [ref, pid] <- :ets.match(@table, {{:listeners, :'$1'}, :'$2'}) do
      {{Process.monitor(pid), pid}, ref}
    end
    {:ok, %State{ monitors: monitors }}
  end

  @doc """
  Inserts a listener into the ets table with a
  monitor reference kept in state.
  """
  @spec handle_call({atom, atom, pid}, {pid, term}, struct) :: {:reply, true | false, struct}
  def handle_call({:set_listener, ref, pid}, _from, %State{monitors: monitors} = state) do
    if :ets.insert_new(@table, {{:listeners, ref}, pid}) do
      m_ref = Process.monitor(pid)
      {:reply, true, %State{ state | monitors: [{{m_ref, pid}, ref}|monitors] }}
    else
      {:reply, false, state}
    end
  end

  @doc """
  Removes the listener from the ets table on exit.
  """
  @spec handle_info({atom, reference, atom, pid, term}, struct) :: {:noreply, struct}
  def handle_info({:'DOWN', m_ref, :process, pid, _}, %State{monitors: monitors} = state) do
    {_, ref} = List.keyfind(monitors, {m_ref, pid}, 0)
    true = :ets.delete(@table, {:listeners, ref})
    {:noreply, %State{ state | monitors: List.keydelete(monitors, {m_ref, pid}, 0) }}
  end
end
