import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import ComposableFieldString from "./ComposableFieldString";
import ComposableFieldNumber from "./ComposableFieldNumber";

export default class ComposableFieldRange extends React.Component {
  render() {
    var className = this.props.fieldSettings.className;
    var fieldClass = "form--small";
    var rangeProps = $.extend(true, {}, this.props);
    var numberProps = $.extend(true, {}, this.props);
    rangeProps.fieldSettings.className = className ? className + fieldClass : fieldClass;
    numberProps.fieldSettings.className = "";
    rangeProps.inputType = "range";

    return(
      <div className="form--range__with-value">
        <ComposableFieldString {...rangeProps} />
        <ComposableFieldNumber {...numberProps} />
      </div>
    )
  }
}

ComposableFieldRange.propTypes = {
  fieldIndex: React.PropTypes.number,
  fieldSettings: React.PropTypes.object,
  value: React.PropTypes.string,
  onChange: React.PropTypes.func
};
