class ComposableField extends React.Component {

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
    return(
      <div className="composable--field-template inputs">
        {this.props.template.map(field => {
          var key = this.props.parentKey + "__" + field.name;
          var fieldType = field.type.replace(/_/g, "");
          var capitalisedFirstType = fieldType.charAt(0).toUpperCase() + fieldType.slice(1);
          var FieldTypeComponent = window["ComposableField" + capitalisedFirstType] || false;
          var wrapperClass = field.wrapperClass || "";
          if(field.data && field.data.length) {
            field.data = this.standardiseData(field.data);
          }
          if(FieldTypeComponent) {
            return(
              <div className={"control-group " + wrapperClass + " " + field.type} key={key}>
                {field.label
                  ? <label className="control-label">{field.label}</label>
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
                                      id={this.props.parentKey + "__" + field.name} 
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
  }
}

/*
{React.createElement(FieldTypeComponent, {
  fieldSettings: field,
  value: this.props.data[field.name]
})}
*/

ComposableField.propTypes = {
  data: React.PropTypes.object,
  template: React.PropTypes.array,
  parentKey: React.PropTypes.string
};
