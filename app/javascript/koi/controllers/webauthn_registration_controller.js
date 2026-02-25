import { Controller } from "@hotwired/stimulus";

export default class WebauthnRegistrationController extends Controller {
  static targets = ["response"];
  static values = {
    options: Object,
  };

  submit(e) {
    if (this.responseTarget.value) return;

    e.preventDefault();
    this.createCredential().then(() => {
      e.target.submit();
    });
  }

  async createCredential() {
    const credential = await navigator.credentials.create(this.options);
    this.responseTarget.value = JSON.stringify(credential.toJSON());
  }

  get options() {
    return {
      publicKey: PublicKeyCredential.parseCreationOptionsFromJSON(
        this.optionsValue,
      ),
    };
  }
}
