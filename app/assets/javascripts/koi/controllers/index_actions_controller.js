import { Controller } from "@hotwired/stimulus";

export default class IndexActionsController extends Controller {
  static targets = ["create", "search"];

  initialize() {
    // debounce search
    this.update = debounce(this, this.update);
  }

  disconnect() {
    clearTimeout(this.timer);
  }

  create() {
    this.createTarget.click();
  }

  search() {
    this.searchTarget.focus();
  }

  clear() {
    this.searchTarget.value = "";
    this.searchTarget.closest("form").requestSubmit();
  }

  update() {
    this.searchTarget.closest("form").requestSubmit();
  }

  submit() {
    if (this.searchTarget.value === "") {
      this.searchTarget.disabled = true;
    }
  }
}

function debounce(self, f) {
  return (...args) => {
    clearTimeout(self.timer);
    self.timer = setTimeout(() => {
      f.apply(self, ...args);
    }, 300);
  };
}
