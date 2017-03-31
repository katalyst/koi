class ComposableFieldSelect extends React.Component {
  render() {
    var options = this.props.fieldSettings.data || [];
    var className = this.props.fieldSettings.className || "form--auto";
    return(
      <select className={className} 
              value={this.props.value} 
              onChange={(event) => this.props.onChange(event, this.props.fieldIndex, this.props.fieldSettings)}>
        {options.map(option => {
          return(
            <option value={option} key={"option__" + Ornament.parameterize(option) }>{option}</option>
          );
        })}
      </select>
    );
  }
}

ComposableField.propTypes = {
  fieldSettings: React.PropTypes.string,
  value: React.PropTypes.string
};
