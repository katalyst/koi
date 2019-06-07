/*

  jQuery minicolors field for react-composable-content

  Note about bindings:
  Because minicolors and React will both fight over setting the value of the 
  input field, we can't just bind jQuery UI datepicker and let it do it's thing.
  We need to make sure that onSelect is then pushing the value back to react-final-form
  so that both React and jQuery UI are in sync with eachother

  We have two refs here, this.$wrapper which is used for jQuery to find the <input>
  element to bind jQuery datepicker to.
  The second is this.$input which is the <Field> react component that we need to pass
  to the setFieldValue helper to set the value in react-final-form

*/

import React from 'react';
import { Field } from 'react-final-form';

let debounceTimer = null;

export default class ComposableFieldColour extends React.Component {

  componentDidMount(){
    if(this.$input) {
      var $input = $(this.$wrapper).find("input");
      $input.minicolors();
      $input.on("change", event => {
        this.debounceUpdate(event.target.value);
      });
    }
  }

  // Due to the dragging interface of the minicolours library you 
  // want to debounce the push back to react so the page doesn't lock up
  debounceUpdate = value => {
    if(debounceTimer) {
      clearTimeout(debounceTimer);
    }
    debounceTimer = setTimeout(() => {
      this.props.helpers.setFieldValue(this.$input, value);
    }, 400);
  }

  render() {
    const props = this.props;
    const data = props.fieldSettings.inputData || {};
    data.colourpicker = "";
    props.fieldSettings.inputData = data;

    return(
      <div className="form--field-wrapper" ref={el => this.$wrapper = el}>
        {this.props.fieldSettings.prefix &&
          <div className="form--field-cap">
            {this.props.fieldSettings.prefix}
          </div>
        }
        <Field
          component="input"
          type={this.props.inputType || "text"}
          ref={el => this.$input = el}
          {...this.props.helpers.generateFieldAttributes(props)}
        />
      </div>
    )
  }
}