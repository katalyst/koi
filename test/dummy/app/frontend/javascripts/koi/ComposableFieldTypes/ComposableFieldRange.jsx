import React from 'react';
import ComposableFieldString from "./ComposableFieldString";
import ComposableFieldNumber from "./ComposableFieldNumber";

export default class ComposableFieldRange extends React.Component {
  render() {
    const rangeProps = { ...this.props };
    rangeProps.fieldSettings.className = "";
    rangeProps.inputType = "range";

    const numberProps = { ...this.props };
    numberProps.inputType = "number";

    return(
      <div className="form--range__with-value">
        <ComposableFieldString {...rangeProps} />
        <ComposableFieldNumber {...numberProps} />
      </div>
    )
  }
}