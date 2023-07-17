import { Controller } from "@hotwired/stimulus";

export default class HistoryController extends Controller {
  static values = {
    url: String,
  }

  urlValueChanged(url) {
    window.history.replaceState({}, "", this.urlValue);
  }
}
