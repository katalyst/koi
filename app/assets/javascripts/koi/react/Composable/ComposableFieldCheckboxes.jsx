class ComposableFieldCheckboxes extends React.Component {

  constructor(props) {
    super(props),
    this.onChangeCollection = this.onChangeCollection.bind(this);
  }

  onChangeCollection(event, field) {
    var data = this.props.value || [];
    var checked = event.target.checked;
    var value = field.name
    var dataIndex = data.indexOf(value);

    if(checked && dataIndex < 0) {
      data.push(value);
    } else if (!checked && dataIndex > -1) {
      data.splice(dataIndex, 1);
    }

    this.props.onChange(data, this.props.fieldIndex, this.props.fieldSettings);
  }

  render() {
    var options = this.props.fieldSettings.data || [];
    var className = this.props.fieldSettings.className || "";
    return(
      <div className="checkboxes" ref="options">
        {options.map((option, index) => {
          var key = Ornament.parameterize(this.props.fieldSettings.name) + "__option-" + index + "__" + option.name;
          return(
            <span className="checkbox" key={key}>
              <label>
                <input type="checkbox" 
                       checked={this.props.value.indexOf(option.value) > -1}
                       className="enhanced" 
                       onChange={(event) => this.onChangeCollection(event, option)} 
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
