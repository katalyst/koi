import { Controller } from "@hotwired/stimulus";

/**
 A stimulus controller to request form submissions.
 This controller should be attached to a form element.
 */
export default class NavigationController extends Controller {
  static targets = ["filter"];

  focus() {
    this.filterTarget.focus();
  }

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

  applyFilter(filter) {
    // hide items that don't match the search filter
    this.element.querySelectorAll("li:has(> a)").forEach((li) => {
      if (this.fuzzySearch(filter.toLowerCase(), li.innerText.toLowerCase())) {
        li.toggleAttribute("hidden", false);
      } else {
        li.toggleAttribute("hidden", true);
      }
    });

    this.element.querySelectorAll("li:has(ul)").forEach((li) => {
      if (!li.matches("li:has(ul > li:not([hidden]))")) {
        li.toggleAttribute("hidden", true);
      }
    });
  }

  clearFilter(filter) {
    this.element.querySelectorAll("li").forEach((li) => {
      li.toggleAttribute("hidden", false);
    });
  }

  // Fuzzysearch
  // https://github.com/bevacqua/fuzzysearch/blob/master/index.js
  fuzzySearch(needle, haystack) {
    const hlen = haystack.length;
    const nlen = needle.length;
    if (nlen > hlen) {
      return false;
    }
    if (nlen === hlen) {
      return needle === haystack;
    }
    outer: for (let i = 0, j = 0; i < nlen; i++) {
      const nch = needle.charCodeAt(i);
      while (j < hlen) {
        if (haystack.charCodeAt(j++) === nch) {
          continue outer;
        }
      }
      return false;
    }
    return true;
  }
}
