// =========================================================================
// Koi CRUD form integrations for Composable Content
// =========================================================================

// Trigger the form validations
const validateForm = function(event, $form, saveAndContinue=false){

  // Prevent submission event
  if(event) {
    event.preventDefault();
  }

  // Fire the validation event
  const validationEvent = new CustomEvent("composable-content:validate");
  document.dispatchEvent(validationEvent);

  // Move to end of event loop so any toggles and errors can be
  // triggered first
  setTimeout(e => {
    // Find any errors
    const errors = $(".composable--composition .error-block");
    
    // Focus on first error
    if(errors.length) {
      const firstError = errors.first();
      const field = firstError.parent().find("input, textarea")[0];

      // Focus on the first errored field
      if(field) {
        field.focus();
      } else {
        scrollTo(0, firstError.offset().top - 100);
      }

    // No errors? Submit form
    } else {
      const form = $form[0];
      const saveType = document.createElement("input");
      saveType.type = "hidden";
      saveType.name = "commit";
      saveType.value = saveAndContinue ? "Continue" : "Submit";
      form.appendChild(saveType);
      form.submit();
    }
  }, 0);
}

// Overiding the form submit functionality to hook in to validation
const bindKoiForms = () => {
  const $form = $("[data-composable-validate]");

  // When form is submitted manually, validate and save page
  $form.on("submit", validateForm);

  // When form is submitted via buttons, validate and either
  // reload or save
  $form.find("button[type=submit]").on("click submit", e => {
    e.preventDefault();
    if(e.currentTarget.value && e.currentTarget.value === "Continue") {
      validateForm(event, $form, true);
    } else {
      validateForm(event, $form);
    }
  });
}

// =========================================================================
// Binding some window helpers to easily enable/disable debug mode
// in your console by calling these functions and storing your call
// in localstorage to persist across pages
//
// enableComposableDebug() = turns debug mode on in the component
// disableComposableDebug() = turns debug mode off
// =========================================================================

const bindKoiDebugFunctions = component => {
  window.enableComposableDebug = window.enableComposableDebug || (() => {
    localStorage.setItem("koiDebugComposable", true);
    component.setDebug(true);
  });

  window.disableComposableDebug = window.disableComposableDebug || (() => {
    localStorage.removeItem("koiDebugComposable");
    component.setDebug();
  });
}

export { bindKoiForms, bindKoiDebugFunctions }