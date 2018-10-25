import React from 'react';
import ComposableField from "../Composable/ComposableField";

export default class ComposableFieldRepeater extends React.Component {

  constructor(props){
    super(props);
    this.addNewItem = this.addNewItem.bind(this);
    this.removeItem = this.removeItem.bind(this);
    this.updateValue = this.updateValue.bind(this);
  }

  // Add a new set of fields to the repeater
  addNewItem(){
    const value = this.props.value || [];
    const fields = this.props.fieldSettings.fields;
    const newItem = {};
    fields.forEach(field => {
      newItem[field.name] = this.props.helpers.getDefaultValueForField(field);
    });
    value.push(newItem);
    this.updateValue(value);
  }

  // Remove an index from the repeater array
  removeItem(index){
    const value = this.props.value;
    if(value[index]) {
      value.splice(index, 1);
    }
    this.updateValue(value);
  }

  // Send updated data
  updateValue(value){
    this.props.helpers.onFieldChangeValue(value, this.props.fieldIndex, this.props.fieldSettings);
  }

  render() {
    const { value } = this.props;
    const field = this.props.fieldSettings;
    const nestedFields = field.fields;
    const overMax = field.max && value.length >= field.max;
    const underMin = field.min && value.length <= field.min;

    // TODO:
    // - Reorder
    
    // Disallow adding new ones by setting a max prop
    const allowAdd = !overMax;

    return(
      <div>
        {nestedFields.length
          ? <div className="composable--repeater--fields inputs">
              <React.Fragment>
                {value.map((repeaterItem,repeaterIndex) => {
                  return(
                    <div key={`${this.props.id}__iteration-${repeaterIndex}`} style={{ "paddingLeft": "20px" }}>
                      <div className="inputs">
                        {nestedFields.map((nestedField, nestedFieldIndex) => {
                          return(
                            <ComposableField
                              key={`${this.props.id}_${nestedFieldIndex}_${nestedField.name}`}
                              componentIndex={nestedFieldIndex}
                              component={this.props.component}
                              fieldNamePrefix={`${field.name}_${repeaterIndex}`}
                              field={nestedField}
                              helpers={this.props.helpers}
                            />
                          )
                        })}
                      </div>
                      <button type="button" onClick={e => this.removeItem(repeaterIndex)}>Remove</button>
                    </div>
                  );
                })}
                {allowAdd &&
                  <button type="button" onClick={this.addNewItem} className="button">+ Add</button>
                }
              </React.Fragment>
            </div>
          : <div class="panel__error">
              Warning: No fields defined for repeater
            </div>
        }
      </div>
    );
  }
}
