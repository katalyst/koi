import React from 'react';
import ComposableFieldTextarea from "./ComposableFieldTextarea";

export default class ComposableFieldRichtext extends React.Component {

  constructor(props) {
    super(props),
    this.afterMount = this.afterMount.bind(this);
    this.afterUnmount = this.afterUnmount.bind(this);
    this.triggerBindings = this.triggerBindings.bind(this);
  }

  triggerBindings() {
    var component = this;
    var $editor = $("#" + this.props.id)[0];
    Ornament.CKEditor.bindForTextarea($editor);
    var instance = CKEDITOR.instances[this.props.id];
    if(instance) {
      instance.on("change", event => {
        var value = event.editor.getData();
        component.props.onChange(value, component.props.fieldIndex, component.props.fieldSettings);
      });
    } else {
      console.warn("Unable to bind CKEditor on change event, possibly too quick?");
    }
  }

  /*
    After mounting this textarea, bind the CKEditor functions
    and start watching for changes to push back up to 
    the main composable component
  */
  afterMount() {
    this.triggerBindings();
    $(document).on("ornament:composable:re-attach-ckeditors", () => {
      this.triggerBindings();
    });
  }

  /*
    When a richtext editor is removed we want to unbind CKEditor
    to stop it listening for things that no longer exist 
  */
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
    // remove default onChange event, this is now routed through the CKEditor.on("change")
    // event in the afterMount callback above
    props.onChange = (event, index, template) => { return false; }

    return(
      <ComposableFieldTextarea {...props} />
    )
  }
}