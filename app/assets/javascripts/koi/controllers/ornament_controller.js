import { Controller } from "@hotwired/stimulus";

/**
 * Hooks to provide support for legacy ornament behaviour in a turbo world.
 */
export default class OrnamentController extends Controller {
  static target = ["layoutContainer"];

  layoutContainerTargetConnected(_el) {
    $(document).trigger("ornament:refresh");

    // let system tests know that the app is ready
    document.body.dataset.ornament = "";
  }
}
