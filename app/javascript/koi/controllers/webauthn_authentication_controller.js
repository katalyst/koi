import { Controller } from "@hotwired/stimulus";

import {
  get,
  parseRequestOptionsFromJSON,
} from "@github/webauthn-json/browser-ponyfill";

export default class WebauthnAuthenticationController extends Controller {
  static targets = ["response"];
  static values = { options: Object };

  authenticate() {
    get(this.options).then((response) => {
      this.responseTarget.value = JSON.stringify(response);

      this.element.requestSubmit();
    });
  }

  get options() {
    return parseRequestOptionsFromJSON(this.optionsValue);
  }
}
