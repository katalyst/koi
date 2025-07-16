import "@hotwired/turbo-rails";
import { initAll } from "@katalyst/govuk-formbuilder";
import "@rails/actiontext";
import "trix";

import "./controllers";
import "./elements";

/** Initialize GOVUK */
function initGOVUK() {
  document.body.classList.toggle("js-enabled", true);
  document.body.classList.toggle(
    "govuk-frontend-supported",
    "noModule" in HTMLScriptElement.prototype,
  );
  initAll();
}

window.addEventListener("turbo:load", initGOVUK);
if (window.Turbo) initGOVUK();
