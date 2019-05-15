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
import Composable from '../Composable/Composable';

// Koi integrations
import customValidations from './validations';
import { bindKoiForms } from './koi-integrations';

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

  // =========================================================================
  // Composable + Integrations
  // =========================================================================

  return(
    <Composable
      {...props}
      onMount={onMount}
      onDragStart={onDragStart}
      onDragEnd={onDragEnd}
      customValidations={customValidations}
      externalSubmission={true}
    />
  )
}