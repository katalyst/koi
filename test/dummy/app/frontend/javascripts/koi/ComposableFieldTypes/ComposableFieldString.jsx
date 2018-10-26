import React from 'react';
import { Field } from 'react-final-form';

export default class ComposableFieldString extends React.Component {
  render() {
    var className = this.props.fieldSettings.className || "form--medium";
    var props = {
      type: this.props.inputType || "text",
      id: this.props.id,
      className: className,
    };
    if(this.props.fieldSettings.placeholder) {
      props.placeholder = this.props.fieldSettings.placeholder;
    }
    var inputData = this.props.fieldSettings.inputData;
    if(inputData) {
      Object.keys(inputData).map(key => {
        props["data-" + key] = inputData[key];
      })
    }
    
    return(
      <Field
        name={this.props.fieldSettings.name}
        component="input"
        {...props}
        {...this.props.fieldSettings.fieldAttributes}
      />
    );
  }
}