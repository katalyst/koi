import { Controller } from "@hotwired/stimulus";

export default class IndexActionsController extends Controller {
  static targets = ["create", "search", "sort"];

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
    const shouldFocus = document.activeElement === this.searchTarget;

    if (this.searchTarget.value === "") {
      this.searchTarget.disabled = true;
    }
    if (this.sortTarget.value === "") {
      this.sortTarget.disabled = true;
    }

    // restore state and focus after submit
    Promise.resolve().then(() => {
      this.searchTarget.disabled = false;
      this.sortTarget.disabled = false;
      if (shouldFocus) {
        this.searchTarget.focus();
      }
    });
  }

  nextPage() {
    this.element.parentElement.querySelector(".pagination .next a").click();
  }

  prevPage() {
    this.element.parentElement.querySelector(".pagination .prev a").click();
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
