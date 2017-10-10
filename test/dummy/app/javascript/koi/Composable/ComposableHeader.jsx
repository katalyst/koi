import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';

export default class ComposableHeader extends React.Component {

  constructor(props) {
    super(props);
  }

  render() {
    return(
      <div className="composable--header">
        <button type="button" onClick={this.props.collapseAll}>Collapse All</button>
        <button type="button" onClick={this.props.showAll}>Show All</button>
      </div>
    );
  }
}

ComposableHeader.propTypes = {
  dataTypes: PropTypes.array,
  addField: PropTypes.func
};

