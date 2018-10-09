import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import * as ComposableTypes from './ComposableFieldTypes';

export default class ComposableField extends React.Component {

  constructor(props) {
    super(props),
    this.standardiseData = this.standardiseData.bind(this);
  }

  standardiseData(data) {
    var standardisedData = [];
    if(typeof(data[0]) !== "object") {
      data.map(datum => {
        standardisedData.push({
          name: datum,
          value: datum
        })
      });
      return standardisedData;
    } else {
      return data;
    }
  }

  render() {
    if(this.props.template && this.props.template.length) {
      return(
        <div className="composable--field-template inputs">
          {this.props.template.map(field => {
            var key = this.props.parentKey + "__" + field.name;
            var fieldType = field.type.replace(/_/g, "");
            var capitalisedFirstType = fieldType.charAt(0).toUpperCase() + fieldType.slice(1);
            var FieldTypeComponent = ComposableTypes["ComposableField" + capitalisedFirstType];
            var wrapperClass = field.wrapperClass || "";
            var fieldId = this.props.parentKey + "__" + field.name;
            if(field.data && field.data.length) {
              field.data = this.standardiseData(field.data);
            }
            if(FieldTypeComponent) {
              return(
                <div className={"control-group " + wrapperClass + " " + field.type} key={key}>
                  {field.label
                    ? <label className="control-label" htmlFor={fieldId}>{field.label}</label>
                    : false
                  }
                  {field.hint 
                    ? <div className="hint-block">
                        {field.hint}
                      </div>
                    : false
                  }
                  <div className="controls">
                    <FieldTypeComponent fieldSettings={field} 
                                        value={this.props.data[field.name]} 
                                        fieldIndex={this.props.fieldIndex} 
                                        id={fieldId} 
                                        onChange={this.props.onChange} 
                    />
                  </div>  
                </div>
              );
            } else {
              return (
                <p key={key}>Unsupported field type: {field.type}</p>
              );
            }
          })}
        </div>
      );
    } else {
      return(
        <div className="composable--field-template inputs">
          <p>This component doesn't offer any configuration.</p>
        </div>
      );
    }
  }
}

/*
{React.createElement(FieldTypeComponent, {
  fieldSettings: field,
  value: this.props.data[field.name]
})}
*/

ComposableField.propTypes = {
  data: PropTypes.object,
  template: PropTypes.array,
  parentKey: PropTypes.string,
  fieldIndex: PropTypes.number,
  onChange: PropTypes.func
};
