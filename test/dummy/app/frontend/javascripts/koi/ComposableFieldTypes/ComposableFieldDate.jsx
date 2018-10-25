import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import ComposableFieldString from "./ComposableFieldString";

export default class ComposableFieldDate extends React.Component {
  render() {
    var className = this.props.fieldSettings.className;
    var fieldClass = "datepicker form--small";
    var props = $.extend(true, {}, this.props);
    props.fieldSettings.className = className ? className + fieldClass : fieldClass;

    return(
      <ComposableFieldString {...props} />
    )
  }
}

ComposableFieldDate.propTypes = {
  fieldIndex: PropTypes.number,
  fieldSettings: PropTypes.object,
  value: PropTypes.string,
  onChange: PropTypes.func
};
