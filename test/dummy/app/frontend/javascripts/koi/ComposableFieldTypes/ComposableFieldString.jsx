import React from 'react';
import { Field } from 'react-final-form';

export default class ComposableFieldString extends React.Component {
  render() {
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
          {...this.props.helpers.generateFieldAttributes(this.props)}
        />
      </div>
    );
  }
}