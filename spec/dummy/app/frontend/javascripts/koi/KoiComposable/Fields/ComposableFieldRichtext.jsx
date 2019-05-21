/*

  CKEditor field for react-composable-content

  The render is made of two <Field> components
  The first is a textarea that the browser is going to replace with CKEditor
  The second is going to be the field that react-final-form is going to watch for
  content changes and store in state.
  This allows CKEditor to work entirely separate from the composition state, only
  pushing changes to the react state when needed.

*/

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

  /*
    Watch for updates to the editor and push them back to 
    react state
  */
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