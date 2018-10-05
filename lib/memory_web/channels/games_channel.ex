defmodule MemoryWeb.GamesChannel do
  use MemoryWeb, :channel

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      if !Memory.Game.game_exists(name) do
        Memory.Game.create_game(name)
      end
      socket = assign(socket, :name, name)
      IO.inspect(Memory.Game.get_game(name))
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (games:lobby).
  def handle_in("get-status", payload, socket) do
    name = socket.assigns[:name]

    send_open(socket)
    broadcast socket, "counter-update", %{ clicks: Memory.Game.get_clicks(name)}
    {:noreply, socket}
  end

  def handle_in("tile-clicked", %{"tile" => tile}, socket) do
    name = socket.assigns[:name]
    IO.inspect(Memory.Game.get_game(name))

    if !Memory.Game.is_locked(name) do
      if !Memory.Game.is_open(name, tile) do
        # The Tile has not been clicked.
        # Check if this is the first tile thats clicked
        # If Yes, Assign it as first.
        Memory.Game.increase_clicks(name)
        Memory.Game.open_tile(name, tile)
        send_open(socket, tile)
        send_counter(socket)

        if !Memory.Game.has_first(name) do
          Memory.Game.set_first(name, tile)
        else
          Memory.Game.set_second(name,tile)
          if !Memory.Game.first_is_second(name) do
            Memory.Game.lock(name)
            Process.sleep(2000)
            Memory.Game.unlock(name)
            Memory.Game.close_tile(name, Memory.Game.get_first(name))
            Memory.Game.close_tile(name, Memory.Game.get_second(name))

            send_close(socket, Memory.Game.get_first(name))
            send_close(socket, Memory.Game.get_second(name))
          end
          Memory.Game.set_first(name, nil)
          Memory.Game.set_second(name, nil)
        end

        # If its the second one.
        # Check if equal letters.
        # If not equal, freeze for 2 seconds. then close both.
        # If Equal, Keep both open
      end
    end
    {:noreply, socket}
  end

  def handle_in("reset-game", _payload, socket) do
    name = socket.assigns[:name]

    Memory.Game.reset_game(name)
    Enum.each(0..15, fn x -> send_close(socket, x) end)

    broadcast socket, "counter-update", %{ clicks: Memory.Game.get_clicks(name)}
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  defp send_counter(socket) do
    name = socket.assigns[:name]
    broadcast socket, "counter-update", %{ clicks: Memory.Game.get_clicks(name)}
  end

  defp send_open(socket, tile) do
    name = socket.assigns[:name]
    broadcast socket, "tile-open",
        %{tile: tile,
          letter: Memory.Game.get_tile(name,tile)}
  end

  defp send_close(socket, tile) do
    name = socket.assigns[:name]
    broadcast socket, "tile-close",
        %{tile: tile}
  end

  defp send_open(socket) do
    name = socket.assigns[:name]
    Enum.each(Memory.Game.get_open_tiles(name), fn open ->
      broadcast socket, "tile-open",
          %{tile: open,
            letter: Memory.Game.get_tile(name,open)}
    end)
  end

end
