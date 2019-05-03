import React from 'react';
import { Field } from 'react-final-form';

export default class ComposableFieldCheckboxes extends React.Component {

  render() {
    const options = this.props.fieldSettings.data || [];
    return(
      <div className="checkboxes" ref="options">
        {options.map((option, index) => {
          var key = Ornament.parameterize(this.props.fieldSettings.name) + "__option-" + index + "__" + Ornament.parameterize(option.label + "");
          return(
            <span className="checkbox" key={key}>
              <label>
                <Field
                  component="input"
                  type="checkbox"
                  value={option.label}
                  {...this.props.helpers.generateFieldAttributes(this.props)}
                />
                <span className='form--enhanced--control'></span>
                {option.label}
              </label>
            </span>
          );
        })}
      </div>
    );
  }
}