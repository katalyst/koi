import { Controller } from "@hotwired/stimulus";
import { Transition } from "koi/utils/transition";

export default class ShowHideController extends Controller {
  static targets = ["content"];

  toggle() {
    const element = this.contentTarget;
    const hide = element.toggleAttribute("data-collapsed");

    // cancel previous animation, if any
    if (this.transition) this.transition.cancel();

    const transition = (this.transition = new Transition(element)
      .addCallback("starting", function () {
        element.setAttribute("data-collapsed-transitioning", "true");
      })
      .addCallback("complete", function () {
        element.removeAttribute("data-collapsed-transitioning");
      }));
    hide ? transition.collapse() : transition.expand();

    transition.start();
  }
}
