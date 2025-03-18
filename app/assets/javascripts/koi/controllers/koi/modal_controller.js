import { Controller } from "@hotwired/stimulus";

export default class ModalController extends Controller {
  static targets = ["dialog"];

  connect() {
    this.element.addEventListener("turbo:submit-end", this.onSubmit);
  }

  disconnect() {
    this.element.removeEventListener("turbo:submit-end", this.onSubmit);
  }

  dismiss() {
    if (!this.dialogTarget) return;
    if (!this.dialogTarget.open) this.dialogTarget.close();

    this.element.removeAttribute("src");
    this.dialogTarget.remove();
  }

  dialogTargetConnected(dialog) {
    dialog.showModal();
  }

  onSubmit = (event) => {
    if (
      event.detail.success &&
      "closeDialog" in event.detail.formSubmission?.submitter?.dataset
    ) {
      this.dialogTarget.close();
      this.element.removeAttribute("src");
      this.dialogTarget.remove();
    }
  };

  noop() {}
}
