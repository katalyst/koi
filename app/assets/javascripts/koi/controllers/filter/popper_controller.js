import { Controller} from "@hotwired/stimulus";
import { createPopper } from "@popperjs/core";

export default class Koi__FilterController extends Controller {
  static targets = ["input", "template"];
  static values = {
    semaphore: { type: Number, default: 0 },
  }

  focus() {
    this.show();
  }

  blur() {
    this.debounce(() => this.hide());
  }

  show() {
    this.semaphoreValue += 1;
  }

  hide() {
    this.semaphoreValue = Math.max(0, this.semaphoreValue - 1);
  }

  disconnect() {
    if (this.tooltip) this.#hide();
  }

  reset() {
    this.semaphoreValue = 0;
  }

  semaphoreValueChanged(value) {
    if (value > 0 && this.tooltip === undefined) {
      this.#show();
    }

    if (value === 0 && this.tooltip) {
      this.#hide();
    }
  }

  #show() {
    this.tooltip = this.#createModal();
    document.body.appendChild(this.tooltip);
    this.popper = createPopper(this.element, this.tooltip, this.options);
  }

  #hide() {
    this.tooltip.remove();
    this.popper.destroy();
    delete this.popper;
    delete this.tooltip;
  }

  #createModal() {
    return this.templateTarget.content.cloneNode(true).firstElementChild;
  }

  debounce = (callback) => {
    clearTimeout(this.timeout);
    this.timeout = setTimeout(callback, 100);
  }

  get options() {
    return {
      placement: "bottom-start",
      modifiers: [
        {
          name: "offset",
          options: {
            offset: [0, 10],
          },
        },
        {
          name: "flip",
          options: {
            fallbackPlacements: ["bottom-start", "top-start"],
          },
        },
        {
          name: "preventOverflow",
          options: {
            padding: 16,
          },
        },
      ],
    }
  }
}
