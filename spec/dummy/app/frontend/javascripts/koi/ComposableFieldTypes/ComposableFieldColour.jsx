import React from 'react';
import ComposableFieldString from "./ComposableFieldString";

export default class ComposableFieldColour extends React.Component {
  render() {
    const props = this.props;
    const data = props.fieldSettings.inputData || {};
    data.colourpicker = "";
    props.fieldSettings.inputData = data;

    return(
      <ComposableFieldString {...props} />
    )
  }
}