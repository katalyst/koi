import { Controller } from "@hotwired/stimulus";

export default class FlashController extends Controller {
  close(e) {
    e.target.closest("li").remove();

    // remove the flash container if there are no more flashes
    if (this.element.children.length === 0) {
      this.element.remove();
    }
  }
}
