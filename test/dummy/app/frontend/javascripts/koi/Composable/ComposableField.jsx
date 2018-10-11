import React from 'react';

import * as ComposableTypes from '../ComposableFieldTypes/ComposableFieldTypes';

export default class ComposableField extends React.Component {

  constructor(props) {
    super(props);
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

    const { field, component, helpers } = this.props;

    const fieldType = field.type.replace(/_/g, "");
    const capitalisedFirstType = fieldType.charAt(0).toUpperCase() + fieldType.slice(1);
    const FieldTypeComponent = ComposableTypes["ComposableField" + capitalisedFirstType];

    const wrapperClass = field.wrapperClass || "";
    const fieldId = component.id + "__" + field.name;
    if(field.data && field.data.length) {
      field.data = this.standardiseData(field.data);
    }

    if(FieldTypeComponent) {
      return(
        <div className={"control-group " + wrapperClass + " " + field.type}>
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
            <FieldTypeComponent
              fieldSettings={field}
              fieldIndex={this.props.componentIndex}
              value={component[field.name]}
              id={fieldId}
              onChange={helpers.onFieldChange}
            />
          </div>
        </div>
      );
    } else {
      return(
        <div className="control-group control__unsupported">
          <p>Unsupported field type: {field.type}</p>
        </div>
      )
    }

  }
}
