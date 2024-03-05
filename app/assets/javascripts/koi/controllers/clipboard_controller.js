import { Controller } from "@hotwired/stimulus";

export default class ClipboardController extends Controller {
  static targets = ["source"];

  static classes = ["supported"];

  connect() {
    if ("clipboard" in navigator) {
      this.element.classList.add(this.supportedClass);
    }
  }

  copy(event) {
    event.preventDefault();
    navigator.clipboard.writeText(this.sourceTarget.value);

    this.element.classList.add("copied");
    setTimeout(() => {
      this.element.classList.remove("copied");
    }, 2000);
  }
}
