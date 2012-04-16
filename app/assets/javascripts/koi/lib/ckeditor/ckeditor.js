var CKEDITOR_BASEPATH = '/assets/ckeditor/';

//= require ckeditor/ckeditor
//= require ckeditor/adapters/jquery

CKEDITOR.replaceByClassEnabled = false;

CKEDITOR.on ('dialogDefinition', function (ev) {

  // Take the dialog name and its definition from the event data.
  var dialogName = ev.data.name;
  var dialogDefinition = ev.data.definition;

  // Check if the definition is from the dialog we're
  // interested on (the Link dialog).
  if ( dialogName == 'link' ) {

    dialogDefinition.removeContents( 'upload' );
    dialogDefinition.removeContents( 'advanced' );
    dialogDefinition.removeContents( 'target' );

    // Enable this part only if you don't remove the 'target' tab in the previous block.
    // Get a reference to the "Target" tab.
    // var targetTab = dialogDefinition.getContents( 'target' );
    // Set the default value for the URL field.
    // var targetField = targetTab.get( 'linkTargetType' );
    // targetField[ 'default' ] = '_blank';
  }

  if (dialogName == 'image') {
    dialogDefinition.removeContents( 'Upload' );
    dialogDefinition.removeContents( 'advanced' );
  }

});
