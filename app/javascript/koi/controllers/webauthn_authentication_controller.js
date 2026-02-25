import { Controller } from "@hotwired/stimulus";

export default class WebauthnAuthenticationController extends Controller {
  static targets = ["response"];
  static values = {
    options: Object,
  };

  async authenticate() {
    const credential = await navigator.credentials.get(this.options);

    this.responseTarget.value = JSON.stringify(credential.toJSON());

    this.element.requestSubmit();
  }

  get options() {
    return {
      publicKey: PublicKeyCredential.parseRequestOptionsFromJSON(
        this.optionsValue,
      ),
    };
  }
}
