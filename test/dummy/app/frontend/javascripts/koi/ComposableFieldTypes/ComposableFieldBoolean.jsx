import React from 'react';
import { Field } from 'react-final-form';

export default class ComposableFieldBoolean extends React.Component {
  render() {
    const className = this.props.fieldSettings.className || "";
    return(
      <label className={"checkbox control-label " + className}>
        <Field
          component="input"
          type="checkbox"
          {...this.props.helpers.generateFieldAttributes(this.props)}
        />
        <span className='form--enhanced--control'></span>
        {this.props.fieldSettings.label}
      </label>
    );
  }
}