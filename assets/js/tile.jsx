import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';


export default function Card({label, open, onclick}) {
  if (open) {
    return (
      <button disabled className="button-disabled green-background memory-tile">
        {label}
      </button>
    );
  } else {
    return (
      <button
        className="memory-tile"
        onClick={onclick}>
        ?
      </button>
    );
  }
}
