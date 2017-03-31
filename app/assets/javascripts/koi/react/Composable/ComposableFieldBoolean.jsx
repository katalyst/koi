class ComposableFieldBoolean extends React.Component {
  render() {
    var options = this.props.fieldSettings.data || [];
    var className = this.props.fieldSettings.className || "";
    return(
      <label className={"checkbox control-label " + className}>
        <input type="checkbox" 
               checked={this.props.value ? this.props.value : false} 
               className="enhanced" 
               onChange={(event) => this.props.onChange(event, this.props.fieldIndex, this.props.fieldSettings)} />
        <span className='form--enhanced--control'></span>
        {this.props.fieldSettings.label}
      </label>
    );
  }
}

ComposableField.propTypes = {
  fieldIndex: React.PropTypes.number,
  fieldSettings: React.PropTypes.string,
  value: React.PropTypes.string,
  onChange: React.PropTypes.func
};
