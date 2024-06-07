import { Controller} from "@hotwired/stimulus";

export default class Koi__ModalController extends Controller {
  static outlets = ["filter--form"]

  selectKey(e) {
    this.filterFormOutlet.addKey(e.target.closest("a").dataset.key);
  }

  selectValue(e) {
    this.filterFormOutlet.addValue(e.target.closest("a").dataset.value);
  }
}
