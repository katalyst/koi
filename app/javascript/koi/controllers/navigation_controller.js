import { Controller } from "@hotwired/stimulus";

export default class NavigationController extends Controller {
  static targets = ["filter"];

  filter() {
    const filter = this.filterTarget.value;
    this.clearFilter(filter);

    if (filter.length > 0) {
      this.applyFilter(filter);
    }
  }

  go() {
    this.element.querySelector("li:not([hidden]) > a").click();
  }

  clear() {
    if (this.filterTarget.value.length === 0) this.filterTarget.blur();
  }

  applyFilter(filter) {
    // hide items that don't match the search filter
    this.links
      .filter(
        (li) =>
          !this.prefixSearch(filter.toLowerCase(), li.innerText.toLowerCase()),
      )
      .forEach((li) => {
        li.toggleAttribute("hidden", true);
      });

    this.menus
      .filter((li) => !li.matches("li:has(li:not([hidden]) > a)"))
      .forEach((li) => {
        li.toggleAttribute("hidden", true);
      });
  }

  clearFilter(filter) {
    this.element.querySelectorAll("li").forEach((li) => {
      li.toggleAttribute("hidden", false);
    });
  }

  prefixSearch(needle, haystack) {
    const haystackLength = haystack.length;
    const needleLength = needle.length;
    if (needleLength > haystackLength) {
      return false;
    }
    if (needleLength === haystackLength) {
      return needle === haystack;
    }
    outer: for (let i = 0, j = 0; i < needleLength; i++) {
      const needleChar = needle.charCodeAt(i);
      if (needleChar === 32) {
        // skip ahead to next space in the haystack
        while (j < haystackLength && haystack.charCodeAt(j++) !== 32) {}
        continue;
      }
      while (j < haystackLength) {
        if (haystack.charCodeAt(j++) === needleChar) continue outer;
        // skip ahead to the next space in the haystack
        while (j < haystackLength && haystack.charCodeAt(j++) !== 32) {}
      }
      return false;
    }
    return true;
  }

  toggle() {
    this.element.open ? this.close() : this.open();
  }

  open() {
    if (!this.element.open) this.element.showModal();
  }

  close() {
    if (this.element.open) this.element.close();
  }

  click(e) {
    if (e.target === this.element) this.close();
  }

  onMorphAttribute = (e) => {
    if (e.target !== this.element) return;

    switch (e.detail.attributeName) {
      case "open":
        e.preventDefault();
    }
  };

  get links() {
    return Array.from(this.element.querySelectorAll("li:has(> a)"));
  }

  get menus() {
    return Array.from(this.element.querySelectorAll("li:has(> ul)"));
  }
}
