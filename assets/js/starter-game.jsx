import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';
import Tile from './tile'

export default function game_init(root, channel) {
  ReactDOM.render(<Starter channel={channel} />, root);
}


/*

Everything is kept in elixir

On new Game:
- Create new Agent with Game empty game state

On Join,
- Send Map of open tiles
- Send number of clicks

- Client -> Server requests
  - tile-clicked: Number of tile
  - game-reset

- Server -> Client requests
  - tile-open: Number, Letter
  - tile-close: Number
  - game-over: total-clicks
  - count-update: total-clicks

Socket Events


*/

const getTile = (x) => {
  return {open: false,
          label: '?',
          index: x}
}

const getLabeledTile = (index, label) => {
  return {open: true,
          label: label,
          index: index}
}

class Starter extends React.Component {
  constructor(props) {
    super(props);

    this.state = {tiles: [...Array(16).keys()].map(key => {return getTile(key)}),
                  clicks: 0}

    this.channel = props.channel;
    this.channel.join()
      .receive("ok", resp => { console.log("Joined successfully", resp) })
      .receive("error", resp => { console.log("Unable to join", resp) });


    this.channel.on('tile-open', msg => {this.tile_opened(msg['tile'],
                                                          msg['letter']);});

    this.channel.on('tile-close', msg => {this.tile_closed(msg['tile']);});

    this.channel.on('game-over', msg => console.log(msg));

    this.channel.on('counter-update',
                      msg => {this.counter_update(msg['clicks']);});

    this.channel.push("get-status", {});
  }

  counter_update(count) {
    console.log("Updated Counter to "+ count)
    this.setState({clicks: count});
  }

  tileClicked(tile) {
    console.log(tile);
    this.channel.push("tile-clicked", {tile: tile})
      .receive("ok", resp => {console.log("Tile-Clicked Resp: ", resp)})
      .receive("error", resp => { console.log("Error", resp) });
  }

  tile_opened(tile,letter) {
    console.log("Tile Opened",tile,letter);
    this.setState((state) => {
      let new_tile = getLabeledTile(tile,letter);
      let tiles = state.tiles;
      tiles[tile] = new_tile;
      return {tiles: tiles};
    });
  }

  tile_closed(tile) {
    console.log("Tile Closed",tile);
    this.setState((state) => {
      let new_tile = getTile(tile);
      let tiles = state.tiles;
      tiles[tile] = new_tile;
      return {tiles: tiles};
    });
  }

  lock() {

  }
  unlock() {

  }

  reset_game() {
    this.channel.push("reset-game", {})
  }

  render() {
    return (
      <div>
        <div>Clicks: {this.state.clicks} </div>
        <div className="container">
          {this.state.tiles.map(tile => {
            let onclick = () => {
              this.tileClicked(tile.index);
            }
            let key = "tile"+tile.index;
            return (<Tile label={tile.label}
                          key={key}
                          open={tile.open}
                          onclick={onclick}></Tile>)
          })}
        </div>
        <button onClick={this.reset_game.bind(this)}>Reset</button>

      </div>);

  }
}
