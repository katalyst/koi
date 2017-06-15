class ComposableFieldRadiobuttons extends React.Component {

  render() {
    var options = this.props.fieldSettings.data || [];
    var className = this.props.fieldSettings.className || "";
    return(
      <div className="radio_buttons" ref="options">
        {options.map((option, index) => {
          var key = Ornament.parameterize(this.props.fieldSettings.name) + "__option-" + index + "__" + option.name;
          return(
            <span className="radio" key={key}>
              <label>
                <input type="radio" 
                       checked={this.props.value.indexOf(option.value) > -1} 
                       value={option.name} 
                       className="enhanced" 
                       onChange={(event) => this.props.onChange(event, this.props.fieldIndex, this.props.fieldSettings)} 
                />
                <span className='form--enhanced--control'></span>
                {option.name}
              </label>
            </span>
          );
        })}
      </div>
    );
  }
}

ComposableField.propTypes = {
  fieldIndex: React.PropTypes.number,
  fieldSettings: React.PropTypes.string,
  value: React.PropTypes.string,
  onChange: React.PropTypes.func
};
