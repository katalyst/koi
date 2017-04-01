class ComposableFieldColour extends React.Component {
  render() {
    var data = this.props.fieldSettings.inputData || [];
    var props = $.extend(true, {}, this.props);
    data.colourpicker = "";
    props.fieldSettings.inputData = data;

    return(
      <ComposableFieldString {...props} />
    )
  }
}

ComposableField.propTypes = {
  fieldIndex: React.PropTypes.number,
  fieldSettings: React.PropTypes.string,
  value: React.PropTypes.string,
  onChange: React.PropTypes.func
};
