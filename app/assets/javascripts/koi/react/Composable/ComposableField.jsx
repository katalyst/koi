class ComposableField extends React.Component {
  render() {
    return(
      <div className="composable--field-template inputs">
        {this.props.template.map(field => {
          var key = this.props.parentKey + "__" + field.name;
          var fieldType = field.type;
          var capitalisedFirstType = fieldType.charAt(0).toUpperCase() + fieldType.slice(1);
          var FieldTypeComponent = window["ComposableField" + capitalisedFirstType] || false;
          if(FieldTypeComponent) {
            return(
              <div className="control-group" key={key}>
                {field.label
                  ? <label className="control-label">{field.label}</label>
                  : false
                }
                <div className="controls">
                  <FieldTypeComponent fieldSettings={field} 
                                      value={this.props.data[field.name]} 
                                      fieldIndex={this.props.fieldIndex} 
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
