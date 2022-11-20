import { Controller } from "@hotwired/stimulus";

/**
 A stimulus controller to request form submissions.
 This controller should be attached to a form element.
 */
export default class extends Controller {
  requestSubmit() {
    this.element.requestSubmit();
  }
}
