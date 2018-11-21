import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';

export default class ComposableFieldString extends React.Component {
  render() {
    var options = this.props.fieldSettings.data || [];
    var className = this.props.fieldSettings.className || "form--medium";
    var props = {
      type: this.props.inputType || "text",
      id: this.props.id,
      className: className,
      value: this.props.value || "",
      onChange: (event) => this.props.onChange(event, this.props.fieldIndex, this.props.fieldSettings)
    };
    if(this.props.fieldSettings.placeholder) {
      props.placeholder = this.props.fieldSettings.placeholder;
    }
    if(this.props.fieldSettings.fieldAttributes) {
      Object.keys(this.props.fieldSettings.fieldAttributes).map(key => {
        props[key] = this.props.fieldSettings.fieldAttributes[key];
      });
    }
    var inputData = this.props.fieldSettings.inputData;
    if(inputData) {
      Object.keys(inputData).map(key => {
        props["data-" + key] = inputData[key];
      })
    }
    return(
      <input {...props} />
    );
  }
}

ComposableFieldString.propTypes = {
  fieldIndex: PropTypes.number,
  fieldSettings: PropTypes.object,
  inputType: PropTypes.string,
  value: PropTypes.string,
  onChange: PropTypes.func
};
