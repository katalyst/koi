import { Controller } from "@hotwired/stimulus";

import {
  create,
  parseCreationOptionsFromJSON,
} from "@github/webauthn-json/browser-ponyfill";

export default class WebauthnRegistrationController extends Controller {
  static values = { options: Object };
  static targets = ["response"];

  submit(e) {
    if (this.responseTarget.value === "") {
      e.preventDefault();
      this.createCredential();
    }
  }

  createCredential() {
    create(this.options).then((response) => {
      this.responseTarget.value = JSON.stringify(response);

      this.element.requestSubmit();
    });
  }

  get options() {
    return parseCreationOptionsFromJSON(this.optionsValue);
  }
}
