import React from 'react';
import { Field } from 'react-final-form';

export default class ComposableFieldString extends React.Component {
  render() {
    return(
      <Field
        component="input"
        type={this.props.inputType || "text"}
        {...this.props.helpers.generateFieldAttributes(this.props)}
      />
    );
  }
}