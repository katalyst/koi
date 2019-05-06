import React from 'react';
import { FieldArray } from 'react-final-form-arrays';
import ComposableField from "../Composable/ComposableField";

export default class ComposableFieldRepeater extends React.Component {

  constructor(props){
    super(props);
  }

  removeItem(fields, index){
    if(confirm("Are you sure?")) {
      fields.remove(index);
    }
  }

  render() {
    const repeater = this.props.fieldSettings;
    const fieldTemplate = {};
    repeater.fields.forEach(field => {
      fieldTemplate[field.name] = "";
    });

    return(
      <FieldArray name={repeater.name}>
        {({ fields }) => (
          <div className="composable--repeater-field inputs">
            {fields.map((repeaterItemName, repeaterItemIndex) => {
              return(
                <div key={repeaterItemName} className="inputs">
                  {repeater.fields.map((field, fieldIndex) => {
                    return(
                      <ComposableField
                        key={`${this.props.id}_${fieldIndex}_${field.name}`}
                        componentIndex={fieldIndex}
                        component={this.props.component}
                        field={field}
                        fieldName={`${repeaterItemName}.${field.name}`}
                        helpers={this.props.helpers}
                      />
                    )
                  })}
                  <button
                    type="button"
                    className="button__cancel"
                    onClick={() => this.removeItem(fields, repeaterItemIndex)}
                  >
                    Remove
                  </button>
                </div>
              );
            })}
            <button
              type="button"
              className="button__success"
              onClick={() => fields.push(fieldTemplate)}
            >
              + Add
            </button>
          </div>
        )}
      </FieldArray>
    )

    /*
    return(
      <div>
        {nestedFields.length
          ? <div className="composable--repeater-field inputs">
              <React.Fragment>
                {value.map((repeaterItem,repeaterIndex) => {
                  return(
                    <div key={`${this.props.id}__iteration-${repeaterIndex}`}>
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
                        <button type="button" onClick={e => this.removeItem(repeaterIndex)} className="button__cancel">Remove</button>
                      </div>
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
    */
  }
}
