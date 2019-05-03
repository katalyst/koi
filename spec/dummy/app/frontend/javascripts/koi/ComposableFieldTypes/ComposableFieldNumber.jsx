import React from 'react';
import ComposableFieldString from "./ComposableFieldString";

export default class ComposableFieldNumber extends React.Component {
  render() {
    const props = { ...this.props };
    props.fieldSettings.className = props.fieldSettings.className || "";
    props.fieldSettings.className += " form--small";
    props.inputType = "number";

    return(
      <ComposableFieldString {...props} />
    )
  }
}