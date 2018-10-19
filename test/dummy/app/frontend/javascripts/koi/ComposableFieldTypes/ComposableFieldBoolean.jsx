import React from 'react';
import PropTypes from 'prop-types';

export default class ComposableFieldBoolean extends React.Component {
  render() {
    const options = this.props.fieldSettings.data || [];
    const className = this.props.fieldSettings.className || "";
    const checked = this.props.value ? this.props.value : false;
    return(
      <label className={"checkbox control-label " + className}>
        <input type="checkbox" 
               checked={checked} 
               className="enhanced" 
               onChange={event => this.props.helpers.onFieldChangeValue(!checked, this.props.fieldIndex, this.props.fieldSettings)} />
        <span className='form--enhanced--control'></span>
        {this.props.fieldSettings.label}
      </label>
    );
  }
}

ComposableFieldBoolean.propTypes = {
  fieldIndex: PropTypes.number,
  fieldSettings: PropTypes.object,
  onChange: PropTypes.func
};
