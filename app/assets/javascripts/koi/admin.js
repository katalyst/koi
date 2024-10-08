import "@hotwired/turbo-rails";
import { initAll } from "@katalyst/govuk-formbuilder";
import "@rails/actiontext";
import "trix";

import "koi/controllers";
import "koi/elements";

/** Let GOVUK know that we've got JS enabled */
window.addEventListener("turbo:load", () => {
  document.body.classList.toggle("js-enabled", true);
  document.body.classList.toggle(
    "govuk-frontend-supported",
    "noModule" in HTMLScriptElement.prototype,
  );
  initAll();
});
