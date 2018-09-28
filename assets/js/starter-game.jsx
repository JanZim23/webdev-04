import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';
import Tile from './tile'

export default function game_init(root) {
  ReactDOM.render(<Starter />, root);
}

const letters = ["A", "B", "C", "D", "E", "F", "G", "H"];

const getTiles = letters.reduce((a, letter) => {
  a.push(Tile.createTile(letter), Tile.createTile(letter));
});


const initialState = () =>
  Object.assign({},
    {
      locked: false,
      tiles: getTiles().sort(() => 0.5 - Math.random() * Math.random()),
      first: false,
      second: false,
    });

class Starter extends React.Component {
  constructor(props) {
    super(props);
    this.state = initialState();

  }

  tileClicked(tile) {
    if(this.state.locked) {

      //Fishy.
      this.state.first.deselect();
      this.state.second.deselect();
      //End Fishy
      unlock();
    }

    if(this.state.first == false) {
      this.setState({first: tile});
      tile.select();
    } else if(this.state.second == false) {
      this.setState({second: tile});
      checkFirstSecond();
    }
  }

  checkFirstSecond() {
    if(this.state.first.props.letter == this.state.second.props.letter) {
      this.state.first.complete();
      this.state.second.complete();
    } else {
      lock();
    }
  }

  lock() {
    this.setState({locked: true});
    //Wait a second and call unlock.
  }
  unlock() {
    this.setState({first: false, second: false});
    this.setState({locked: false});
  }

  render() {
    return this.state.tiles.join();
  }
}
