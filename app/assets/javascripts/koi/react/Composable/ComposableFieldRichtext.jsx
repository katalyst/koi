class ComposableFieldRichtext extends React.Component {

  constructor(props) {
    super(props),
    this.afterMount = this.afterMount.bind(this);
    this.afterUnmount = this.afterUnmount.bind(this);
  }

  afterMount() {
    var component = this;
    var $editor = $("#" + this.props.id)[0];
    Ornament.CKEditor.bindForTextarea($editor);
    instance = CKEDITOR.instances[this.props.id];
    if(instance) {
      instance.on("change", event => {
        var value = event.editor.getData();
        component.props.onChange(value, component.props.fieldIndex, component.props.fieldSettings);
      });
    } else {
      console.warn("Unable to bind CKEditor on change event, possibly too quick?");
    }
  }

  afterUnmount() {
    var instance = CKEDITOR.instances[this.props.id];
    if(instance) {
      instance.destroy();
    }
  }

  render() {
    var className = this.props.fieldSettings.className;
    var wysiwygClass = "wysiwyg source";
    var props = $.extend(true, {}, this.props);
    // set wysiwyg class
    props.fieldSettings.className = className ? className + wysiwygClass : wysiwygClass;
    // add on mount/unmount callbacks
    props.afterMount = this.afterMount;
    props.afterUnmount = this.afterUnmount;
    props.onChange = (event, index, template) => { return false; }

    return(
      <ComposableFieldTextarea {...props} />
    )
  }
}

ComposableField.propTypes = {
  fieldIndex: React.PropTypes.number,
  fieldSettings: React.PropTypes.string,
  value: React.PropTypes.string,
  onChange: React.PropTypes.func
};
