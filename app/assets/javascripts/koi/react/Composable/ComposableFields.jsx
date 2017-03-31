class ComposableFields extends React.Component {
  render() {
    var component = this;
    var data = this.props.data;
    if(data.length) {
      return(
        <div className="composabe--fields">
          {data.map((datum, index) => {
            var key = "composable_index_" + datum.id + "_type_" + datum.type;
            var template = this.props.getTemplateForField(datum.type);
            return(
              <div className="composable--field" key={key}>
                <div className="composable--field-heading">
                  <span className="composable--field-heading--type">{template ? template.name : `Unsupported field type (${datum.type})` }</span>
                  <button className="composable--field-heading--remove" type="button" onClick={() => this.props.removeField(index)}>Remove</button>
                  {data.length > 1 && index !== 0
                    ? <button className="composable--field-heading--up" type="button" onClick={(event) => this.props.moveFieldBy(datum,-1)}>-1</button>
                    : false
                  }
                  {data.length > 1 && index !== (data.length - 1)
                    ? <button className="composable--field-heading--down" type="button" onClick={(event) => this.props.moveFieldBy(datum,1)}>+1</button>
                    : false
                  }
                  <span className="drag-handler">Drag to Reorder</span>
                </div>
                {template 
                  ? <ComposableField 
                      template={template.fields} 
                      data={datum} 
                      parentKey={key} 
                      fieldIndex={index} 
                      onChange={this.props.onFieldChange}
                    />
                  : <div className="composable--field--unsupported">
                      <p>There is no available template for this field type</p>
                    </div>
                }
              </div>
            );
          })}
        </div>
      );
    } else {
      return(
        <div className="composable--fields__empty">
          <p>There are no fields</p>
        </div>
      );
    }
  }
}

ComposableFields.propTypes = {
  data: React.PropTypes.array,
  dataTypes: React.PropTypes.array,
  removeField: React.PropTypes.func,
  moveFieldBy: React.PropTypes.func,
  onFieldChange: React.PropTypes.func,
  getTemplateForField: React.PropTypes.func
};
