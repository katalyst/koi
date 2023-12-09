import "@hotwired/turbo-rails";
import "@rails/actiontext";
import "trix";

import "koi/controllers";

/** Let GOVUK know that we've got JS enabled */
window.addEventListener("turbo:load", () => {
  document.body.classList.toggle("js-enabled", true);
  document.body.classList.toggle("govuk-frontend-supported", ('noModule' in HTMLScriptElement.prototype));
});
