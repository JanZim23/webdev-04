defmodule Memory.Game do
  use Agent

  def letters do
    ["A","B","C","D","E","F","G","H","A","B","C","D","E","F","G","H"]
  end

  def empty_game do
    %{
      tiles: random_tiles(),
      open: [],
      locked: false,
      clicks: 0,
      first: nil,
      second: nil,
    }
  end

  def random_tiles do
    Enum.shuffle(letters())
  end

  def start_link(_args) do
    Agent.start_link(fn -> Map.new end, name: __MODULE__)
  end

  def create_game(name) do
    Agent.update(__MODULE__, fn games ->
      Map.put(games, name, empty_game())
    end)
  end

  def game_exists(name) do
    Agent.get(__MODULE__, fn games ->
      Map.has_key?(games, name) end)
  end

  def reset_game(name) do
      create_game(name)
  end

  def get_game(name) do
    Agent.get(__MODULE__, fn games -> games[name] end)
  end

  def update_game(name, key, val) do
    Agent.update(__MODULE__, fn games ->
      game = games[name]
      Map.put(games, name,
        Map.put(game, key, val))
    end)
  end

  def increase_clicks(name) do
    Agent.update(__MODULE__, fn games ->
      game = games[name]
      gameclicks = game[:clicks]
      Map.put(games, name,
        Map.put(game, :clicks, gameclicks + 1))
    end)
  end

  def get_clicks(name) do
    get_game(name)[:clicks]
  end

  def get_tile(name, tile) do
    game = get_game(name)
    Enum.at(game[:tiles], tile)
  end

  def get_open_tiles(name) do
    get_game(name)[:open]
  end

  def is_open(name, tile) do
    Enum.member?(get_open_tiles(name), tile)
  end

  def tile_clicked(name, tile) do
    #Ignore if the tile is already open
    if !is_open(name,tile) do
      letter = get_tile(name,tile)
    end
  end

  def open_tile(name, tile) do
    Agent.update(__MODULE__, fn games ->
      game = games[name]
      Map.put(games, name,
        Map.put(game, :open, game[:open] ++ [tile]))
    end)
  end

  def close_tile(name,tile) do
    Agent.update(__MODULE__, fn games ->
      game = games[name]
      Map.put(games, name,
        Map.put(game, :open, Enum.filter(game[:open], fn x -> x != tile end)))
    end)
  end

  def is_locked(name) do
    get_game(name)[:locked]
  end

  def lock(name) do
    update_game(name, :locked, true)
  end

  def unlock(name) do
    update_game(name, :locked, false)
  end

  def has_first(name) do
    get_game(name)[:first] != nil
  end

  def set_first(name, tile) do
    update_game(name, :first, tile)
  end

  def get_first(name) do
    get_game(name)[:first]
  end

  def set_second(name, tile) do
    update_game(name, :second, tile)
  end

  def get_second(name) do
    get_game(name)[:second]
  end

  def first_is_second(name) do
    get_tile(name,get_first(name)) == get_tile(name,get_second(name))
  end





end
