import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';


const createTile = (letter) => {
  return (<Tile
            letter={letter}
            label={letter}
            selected={false}
            complete={false}
            onclick={false}
            />);
}

class Tile extends React.Component {
  constructor(props) {
    props.onclick = () => {Starter.tileClicked(this);};
    super(props)
    this.state= {selected, complete};
  }

  select() {
    this.setState({selected: true});
  }

  deselect() {
    this.setState({selected: false});
  }

  complete() {
    this.setState({complete: true});
  }


  render() {
    if(this.state.complete) {
      return (<button disabled>{this.props.label}</button>);
    } else if (selected) {
      return (<button disabled>{this.props.label}</button>);
    } else {
      return (<button onClick={this.props.onclick}>?</button>);
    }
  }
}
