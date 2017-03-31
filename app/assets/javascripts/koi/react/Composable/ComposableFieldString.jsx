class ComposableFieldString extends React.Component {
  render() {
    var options = this.props.fieldSettings.data || [];
    var className = this.props.fieldSettings.className || "form--medium";
    return(
      <input type="text" 
             className={className} 
             value={this.props.value} 
             onChange={(event) => this.props.onChange(event, this.props.fieldIndex, this.props.fieldSettings)} 
      />
    );
  }
}

ComposableField.propTypes = {
  fieldSettings: React.PropTypes.string,
  value: React.PropTypes.string
};
