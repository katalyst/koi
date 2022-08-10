import { Controller } from "@hotwired/stimulus";

export default class EditController extends Controller {
  static targets = ["state"];

  connect() {
    this.versionState = this.stateTarget.dataset.state;
  }

  change(e) {
    if (e.detail && e.detail.hasOwnProperty("dirty")) {
      this.update(e.detail);
    }
  }

  update({ dirty }) {
    if (dirty) {
      this.stateTarget.dataset.state = "dirty";
    } else {
      this.stateTarget.dataset.state = this.versionState;
    }
  }
}
