class ComposableFieldString extends React.Component {
  render() {
    var options = this.props.fieldSettings.data || [];
    var className = this.props.fieldSettings.className || "form--medium";
    var props = {
      type: "text",
      className: className,
      value: this.props.value,
      onChange: (event) => this.props.onChange(event, this.props.fieldIndex, this.props.fieldSettings)
    };
    if(this.props.fieldSettings.placeholder) {
      props.placeholder = this.props.fieldSettings.placeholder;
    }
    var inputData = this.props.fieldSettings.inputData;
    if(inputData) {
      Object.keys(inputData).map(key => {
        props["data-" + key] = inputData[key];
      })
    }
    return(
      <input {...props} />
    );
  }
}

ComposableField.propTypes = {
  fieldIndex: React.PropTypes.number,
  fieldSettings: React.PropTypes.string,
  value: React.PropTypes.string,
  onChange: React.PropTypes.func
};
