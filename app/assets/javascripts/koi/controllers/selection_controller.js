import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo-rails";

export default class SelectionController extends Controller {
  static values = {
    selected: Array,
    template: String,
  }

  submit(e) {
    if (this.selectedValue.length === 0) {
      e.preventDefault();
      return;
    }

    const templateUrl = e.submitter.formAction;
    e.submitter.formAction = e.submitter.formAction.replace("%5B%5D", this.selectedValue.join(","));

    if (e.submitter.dataset.selectionAction === "reset") {
      this.selectedValue = [];
    }

    if (e.submitter.getAttribute("formmethod") === "get") {
      e.preventDefault();
      Turbo.visit(e.submitter.formAction)
    }

    setTimeout(() => {
      e.submitter.formAction = templateUrl;
    });
  }

  add(selection) {
    if (this.isSelected(selection)) return;

    this.selectedValue = [...this.selectedValue, selection];
  }

  remove(selection) {
    this.selectedValue = this.selectedValue.filter((id) => id !== selection);
  }

  isSelected(selected) {
    return this.selectedValue.indexOf(selected) >= 0;
  }
}
