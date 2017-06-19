import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import ComposableFieldString from "./ComposableFieldString";

export default class ComposableFieldColour extends React.Component {
  render() {
    var data = this.props.fieldSettings.inputData || [];
    var props = $.extend(true, {}, this.props);
    data.colourpicker = "";
    props.fieldSettings.inputData = data;

    return(
      <ComposableFieldString {...props} />
    )
  }
}

ComposableFieldColour.propTypes = {
  fieldIndex: React.PropTypes.number,
  fieldSettings: React.PropTypes.object,
  value: React.PropTypes.string,
  onChange: React.PropTypes.func
};
