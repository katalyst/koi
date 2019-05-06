import React from 'react';
import ComposableFieldString from "./ComposableFieldString";

export default class ComposableFieldDate extends React.Component {
  render() {
    const props = this.props;
    const data = props.fieldSettings.inputData || {};
    props.fieldSettings.inputData = data;
    props.fieldSettings.className = props.fieldSettings.className || "";
    props.fieldSettings.className += " datepicker form--small";

    return(
      <ComposableFieldString {...props} />
    )
  }
}