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
      // TODO: Better default value based on type
      // compare with Composable.jsx and use the same function
      // eg. setDefaultValue(field.type);
      newItem[field.name] = "";
    });
    value.push(newItem);
    this.updateValue(value);
  }

  // Remove an index from the repeater array
  removeItem(index){
    const value = this.props.value;
    if(value[index]) {
      delete value[index];
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

    // TODO:
    // - Max limit
    // - Min limit
    // - Reorder

    return(
      <div>
        {nestedFields.length
          ? <div className="composable--repeater--fields inputs">
              <React.Fragment>
                {value.map((valueItem,valueIndex) => {
                  return(
                    <div key={`${this.props.id}__iteration-${valueIndex}`} style={{ "paddingLeft": "20px" }}>
                      <div className="inputs">
                        {nestedFields.map((field, fieldIndex) => {
                          return(
                            <ComposableField
                              key={`${this.props.id}_${field.name}`}
                              componentIndex={fieldIndex}
                              component={valueItem}
                              field={field}
                              helpers={this.props.helpers}
                            />
                          )
                        })}
                      </div>
                      <button type="button" onClick={e => this.removeItem(valueIndex)}>Remove</button>
                    </div>
                  );
                })}
                <button type="button" onClick={this.addNewItem} className="button">+ Add</button>
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
