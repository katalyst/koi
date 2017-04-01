class ComposableFieldNumber extends React.Component {
  render() {
    var className = this.props.fieldSettings.className;
    var fieldClass = " form--small";
    var props = $.extend(true, {}, this.props);
    props.fieldSettings.className = className ? className + fieldClass : fieldClass;
    props.inputType = "number";

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
