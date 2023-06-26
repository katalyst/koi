import { Controller } from "@hotwired/stimulus";

export default class SelectableController extends Controller {
  static outlets = ["selection"]

  selectionOutletConnected() {
    if (this.selectionOutlet.isSelected(this.element.id)) {
      this.element.checked = true;
    }
  }

  toggle(e) {
    if (this.element.checked) {
      this.selectionOutlet.add(this.element.id);
    } else {
      this.selectionOutlet.remove(this.element.id);
    }
  }
}
