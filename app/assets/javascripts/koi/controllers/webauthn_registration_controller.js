import { Controller } from "@hotwired/stimulus";

export default class WebauthnRegistrationController extends Controller {
  static values = {
    options: Object,
    response: Object,
  };
  static targets = ["intro", "nickname", "response"];

  submit(e) {
    if (
      this.responseTarget.value === "" &&
      e.submitter.formMethod !== "dialog"
    ) {
      e.preventDefault();
      this.createCredential().then();
    }
  }

  async createCredential() {
    const credential = await navigator.credentials.create(this.options);

    this.responseValue = credential.toJSON();
    this.responseTarget.value = JSON.stringify(credential.toJSON());
  }

  responseValueChanged(response) {
    const responsePresent = response !== "";
    this.introTarget.toggleAttribute("hidden", responsePresent);
    this.nicknameTarget.toggleAttribute("hidden", !responsePresent);
  }

  get options() {
    return {
      publicKey: PublicKeyCredential.parseCreationOptionsFromJSON(
        this.optionsValue.publicKey,
      ),
    };
  }
}
