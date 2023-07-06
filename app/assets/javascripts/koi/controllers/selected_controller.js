import { Controller } from "@hotwired/stimulus";

export default class SelectedController extends Controller {
  static targets = ["selectedActions", "unselectedActions", "number"];

  selectedValueChanged(selected) {
    this.selectedActionsTarget.toggleAttribute("hidden", selected.length === 0);
    this.unselectedActionsTarget.toggleAttribute("hidden", selected.length > 0);
    this.numberTarget.innerText = selected.length;
  }
}
