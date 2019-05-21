import React from 'react';
import { Field } from 'react-final-form';

export default class ComposableFieldColour extends React.Component {
  render() {
    const props = this.props;
    const data = props.fieldSettings.inputData || {};
    data.colourpicker = "";
    props.fieldSettings.inputData = data;

    return(
      <div className="form--field-wrapper">
        {this.props.fieldSettings.prefix &&
          <div className="form--field-cap">
            {this.props.fieldSettings.prefix}
          </div>
        }
        <Field
          component="input"
          type={this.props.inputType || "text"}
          {...this.props.helpers.generateFieldAttributes(props)}
        />
      </div>
    )
  }
}