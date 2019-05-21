/*

  jQuery UI Datepcker field for react-composable-content

  Note about bindings:
  Because jQuery UI and React will both fight over setting the value of the 
  input field, we can't just bind jQuery UI datepicker and let it do it's thing.
  We need to make sure that onSelect is then pushing the value back to react-final-form
  so that both React and jQuery UI are in sync with eachother

  We have two refs here, this.$wrapper which is used for jQuery to find the <input>
  element to bind jQuery datepicker to.
  The second is this.$input which is the <Field> react component that we need to pass
  to the setFieldValue helper to set the value in react-final-form

  Settings:
  Your field conifg can take advantage of a `datePickerSettings` prop to plug
  custom settings in to jQuery UI datepicker:

  {
    name: "date",
    label: "Choose a  date",
    type: "date",
    datePickerSettings: {
      "minDate": 0,
    },
  }

*/

import React from 'react';
import { Field } from 'react-final-form';

export default class ComposableFieldDate extends React.Component {

  componentDidMount(){
    if(this.$input) {

      // Default settings
      const settings = {
        dateFormat: 'dd/mm/yy',
        showButtonPanel: true,
        changeMonth: true,
        changeYear: true,

        // Custom settings via the datePickerSettings prop
        ...this.props.fieldSettings.datePickerSettings,

        // Making sure our onSelect is pushing data to react-final-form
        onSelect: dateText => {
          this.props.helpers.setFieldValue(this.$input, dateText);
        }
      }

      // Bind jQueryUI Datepicker
      $(this.$wrapper).find("input").datepicker(settings);
    }
  }

  render() {

    // Forcing className to be small field regardless of what the developer
    // defines
    const props = this.props;
    props.fieldSettings.className = props.fieldSettings.className || "";
    props.fieldSettings.className += " form--small";

    return(
      <div className="form--field-wrapper" ref={el => this.$wrapper = el}>
        {this.props.fieldSettings.prefix &&
          <div className="form--field-cap">
            {this.props.fieldSettings.prefix}
          </div>
        }
        <Field
          component="input"
          type="text"
          ref={el => this.$input = el}
          {...this.props.helpers.generateFieldAttributes(props)}
        />
      </div>
    )
  }
}