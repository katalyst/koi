import { Controller } from "@hotwired/stimulus";

export default class PagyNavController extends Controller {
  connect() {
    document.addEventListener("shortcut:page-prev", this.prevPage);
    document.addEventListener("shortcut:page-next", this.nextPage);
  }

  disconnect() {
    document.removeEventListener("shortcut:page-prev", this.prevPage);
    document.removeEventListener("shortcut:page-next", this.nextPage);
  }

  nextPage = () => {
    this.element.querySelector("a:last-child").click();
  };

  prevPage = () => {
    this.element.querySelector("a:first-child").click();
  };
}
