/**
 * A custom multi-select menu widget using Select2.
 */

import { Controller } from "@hotwired/stimulus";

export default class Select2Controller extends Controller {
  connect() {
    $(this.element).select2();
  }
}
