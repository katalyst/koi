/*

  This is an example custom field type for Composable Content

  Assuming you're creating a component called ComposableFieldCustom, first you'll want 
  to include this file in KoiComposable:
  import ComposableFieldCustom from './Fields/ComposableFieldCustom';

  Then you'll want to add it to the customFormFieldComponent prop when rendering
  <Composable> in KoiComposable:

  <Composable
    ...
    customFormFieldComponents={{
      ComposableFieldCustom,
    }}
  />

  Now you'll be able to use it in your components config:
  {
    name: "Component wtih a custom field",
    slug: "component_custom",
    fields: [{
      name: "My custom field",
      type: "custom",
    }]
  }

  There are several helper functions available to you in this file, all under
  this.props.helpers:
  
  generateFieldAttributes
  Generates HTML attributes you'd typically see on an <input> tag based on the
  composable field config

  getDefaultValueForField
  Gets a logical default value for a specific field type
  Probably not too helpful if you're developing something really custom

  getFieldValue
  Helper to get the current field value out of react-final-form

  setFieldValue
  Helper to set the current field value in react-final-form
  This is helpful if you have a programatic function that sets the value
  of a hidden input field

*/

import React from 'react';
import { Field } from 'react-final-form';

export default class ComposableFieldCustom extends React.Component {
  render() {
    return(
      <div className="form--field-wrapper">
        <Field
          component="input"
          type={this.props.inputType || "text"}
          {...this.props.helpers.generateFieldAttributes(this.props)}
        />
      </div>
    );
  }
}