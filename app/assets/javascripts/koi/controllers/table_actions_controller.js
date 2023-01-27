import { Controller } from "@hotwired/stimulus";

export default class TableActionsController extends Controller {
  static targets = ["create", "search", "reset"]

  create() {
    this.createTarget.click();
  }

  search() {
    this.searchTarget.focus();
  }

  clear() {
    this.resetTarget.click();
  }
}
