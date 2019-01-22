import React from 'react';
import { Field } from 'react-final-form';

export default class ComposableFieldRadiobuttons extends React.Component {

  render() {
    const options = this.props.fieldSettings.data || [];
    return(
      <div className="radio_buttons" ref="options">
        {options.map((option, index) => {
          var key = Ornament.parameterize(this.props.fieldSettings.name) + "__option-" + index + "__" + Ornament.parameterize(option.label + "");
          return(
            <span className="radio" key={key}>
              <label>
                <Field
                  component="input"
                  type="radio"
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