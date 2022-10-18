import { Controller } from "@hotwired/stimulus";

/**
 * Connect an input (e.g. title) to slug.
 */
export default class SluggableController extends Controller {
  static targets = ["source", "slug"];
  static values = {
    slug: String,
  };

  sourceChanged(e) {
    if (this.slugValue === "") {
      this.slugTarget.value = parameterize(this.sourceTarget.value);
    }
  }

  slugChanged(e) {
    this.slugValue = this.slugTarget.value;
  }
}

function parameterize(input) {
  return input
    .toLowerCase()
    .replace(/'/g, "-")
    .replace(/[^-\w\s]/g, "")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/(^-|-$)/g, "");
}
