/*

  KoiComposable

  This is the Koi version of Composable Content that wraps a bunch
  of integrations around the Composable Content react components such
  as being able to define custom validations and custom field types

  Want to add custom field types?
  Look at ./Fields/_example.jsx for more info

  Want to add custom validations?
  Look at ./validations.js for more info

*/

import React from 'react';
import Composable from 'react-composable-content';

// Koi integrations
import customValidations from './validations';
import { bindKoiForms } from './koi-integrations';

// Custom fields
import ComposableFieldAsset from './Fields/ComposableFieldAsset';
import ComposableFieldColour from './Fields/ComposableFieldColour';
import ComposableFieldDate from './Fields/ComposableFieldDate';
import ComposableFieldRichtext from './Fields/ComposableFieldRichtext';

export default function KoiComposable(props) {

  // =========================================================================
  // Callbacks
  // =========================================================================

  // When the Composable component mounts
  const onMount = () => {
    bindKoiForms();
  }

  // Processing on elements when picking them up
  // Reordering CKEditors will break the editors
  // a workaround is to disable the CKEditor when dragging
  // and then renable them when dropping
  const onDragStart = (start, provided) => {
    if(start.source.droppableId === "composition") {
      Ornament.CKEditor.destroyForParent($(".composable--composition"), true);
    }
  }

  // Re-enable CKEditors
  const onDragEnd = (result, provided) => {
    $(document).trigger("composable:re-attach-ckeditors");
  }

  // Whenever a component is added, enhance the forms
  // eg. datepickers, colour pickers, enhanced form fields
  const onComponentAdd = () => {
    $(document).trigger("ornament:enhance-forms");
  }

  // =========================================================================
  // Composable + Integrations
  // =========================================================================

  return(
    <Composable
      {...props}
      draftMode={true}
      onMount={onMount}
      onDragStart={onDragStart}
      onDragEnd={onDragEnd}
      onComponentAdd={onComponentAdd}
      customValidations={customValidations}
      customFormFieldComponents={{
        ComposableFieldAsset,
        ComposableFieldColour,
        ComposableFieldDate,
        ComposableFieldRichtext,
      }}
      externalSubmission={true}
    />
  )
}