import { Controller } from "@hotwired/stimulus";

import {
  create,
  parseCreationOptionsFromJSON,
} from "@github/webauthn-json/browser-ponyfill";

export default class WebauthnRegistrationController extends Controller {
  static values = {
    options: Object,
    response: String,
  };
  static targets = ["intro", "nickname", "response"];

  submit(e) {
    if (this.responseTarget.value === "") {
      e.preventDefault();
      this.createCredential();
    }
  }

  async createCredential() {
    const response = await create(this.options);

    this.responseValue = JSON.stringify(response);
    this.responseTarget.value = JSON.stringify(response);
  }

  responseValueChanged(response) {
    const responsePresent = response !== "";
    this.introTarget.toggleAttribute("hidden", responsePresent);
    this.nicknameTarget.toggleAttribute("hidden", !responsePresent);
  }

  get options() {
    return parseCreationOptionsFromJSON(this.optionsValue);
  }
}
