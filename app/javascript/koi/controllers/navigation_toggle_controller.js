import { Controller } from "@hotwired/stimulus";

export default class NavigationToggleController extends Controller {
  trigger() {
    this.dispatch("toggle", { prefix: "navigation", bubbles: true });
  }
}
