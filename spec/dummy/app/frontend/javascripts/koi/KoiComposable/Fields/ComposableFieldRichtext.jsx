import React from 'react';
import { Field } from 'react-final-form';

export default class ComposableFieldRichtext extends React.Component {

  /*
    After mounting this textarea, bind the CKEditor functions
    and start watching for changes to push back up to 
    the main composable component
  */
  componentDidMount() {
    this.triggerBindings();
    $(document).on("composable:re-attach-ckeditors", () => {
      this.triggerBindings();
    });
  }

  /*
    When a richtext editor is removed we want to unbind CKEditor
    to stop it listening for things that no longer exist 
  */
  componentWillUnmount() {
    var instance = CKEDITOR.instances[this.props.id];
    if(instance) {
      instance.destroy();
    }
  }

  triggerBindings = () => {
    var $editor = $("#" + this.props.id)[0];
    Ornament.CKEditor.bindForTextarea($editor);
    var instance = CKEDITOR.instances[this.props.id];
    if(instance) {
      instance.on("change", event => {
        var value = event.editor.getData();
        this.props.helpers.setFieldValue(this.$hiddenField, value);
      });
    } else {
      console.warn("Unable to bind CKEditor on change event, possibly too quick?");
    }
  }

  render() {
    var className = this.props.fieldSettings.className;
    var wysiwygClass = " wysiwyg source";
    const richTextProps = { ...this.props };
    richTextProps.fieldSettings = richTextProps.fieldSettings || {};
    richTextProps.fieldSettings.className = className ? className + wysiwygClass : wysiwygClass;

    return(
      <React.Fragment>
        <Field
          component="textarea"
          type="text"
          {...this.props.helpers.generateFieldAttributes(this.props)}
        />
        <Field
          name={this.props.fieldSettings.name}
          component="input"
          type="hidden"
          ref={el => this.$hiddenField = el}
          {...this.props.helpers.generateFieldAttributes(this.props)}
        />
      </React.Fragment>
    )
  }
}