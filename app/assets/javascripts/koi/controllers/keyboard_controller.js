import { Controller } from "@hotwired/stimulus";

const DEBUG = false;

export default class KeyboardController extends Controller {
  static values = {
    mapping: String,
    depth: { type: Number, default: 2 },
  };

  event(cause) {
    if (isFormField(cause.target) || this.#ignore(cause)) return;

    const key = this.describeEvent(cause);

    this.buffer = [...(this.buffer || []), key].slice(0 - this.depthValue);

    if (DEBUG) console.debug("[keyboard] buffer:", ...this.buffer);

    // test whether the tail of the buffer matches any of the configured chords
    const action = this.buffer.reduceRight((mapping, key) => {
      if (typeof mapping === "string" || typeof mapping === "undefined") {
        return mapping;
      } else {
        return mapping[key];
      }
    }, this.mappings);

    // if we don't have a string we may have a miss or an incomplete chord
    if (typeof action !== "string") return;

    // clear the buffer and prevent the key from being consumed elsewhere
    this.buffer = [];
    cause.preventDefault();

    if (DEBUG) console.debug("[keyboard] event: %s", action);

    // fire the configured event
    const event = new CustomEvent(action, {
      detail: { cause: cause },
      bubbles: true,
    });
    cause.target.dispatchEvent(event);
  }

  /**
   * @param event KeyboardEvent input event to describe
   * @return String description of keyboard event, e.g. 'C-KeyV' (CTRL+V)
   */
  describeEvent(event) {
    return [
      event.ctrlKey && "C",
      event.metaKey && "M",
      event.altKey && "A",
      event.shiftKey && "S",
      event.code,
    ]
      .filter((w) => w)
      .join("-");
  }

  /**
   * Build a tree for efficiently looking up key chords, where the last key in the sequence
   * is the first key in tree.
   */
  get mappings() {
    const inputs = this.mappingValue
      .replaceAll(/\s+/g, " ")
      .split(" ")
      .filter((f) => f.length > 0);
    const mappings = {};

    inputs.forEach((mapping) => this.#parse(mappings, mapping));

    // memoize the result
    Object.defineProperty(this, "mappings", {
      value: mappings,
      writable: false,
    });

    return mappings;
  }

  /**
   * Parse a key chord pattern and an event and store it in the inverted tree lookup structure.
   *
   * @param mappings inverted tree lookup for key chords
   * @param mapping input definition, e.g. "C-KeyC+C-KeyV->paste"
   */
  #parse(mappings, mapping) {
    const [pattern, event] = mapping.split("->");
    const keys = pattern.split("+");
    const first = keys.shift();

    mappings = keys.reduceRight(
      (mappings, key) => (mappings[key] ||= {}),
      mappings,
    );
    mappings[first] = event;
  }

  /**
   * Ignore modifier keys, as they will be captured in normal key presses.
   *
   * @param event KeyboardEvent
   * @returns {boolean} true if key event should be ignored
   */
  #ignore(event) {
    switch (event.code) {
      case "ControlLeft":
      case "ControlRight":
      case "MetaLeft":
      case "MetaRight":
      case "ShiftLeft":
      case "ShiftRight":
      case "AltLeft":
      case "AltRight":
        return true;
      default:
        return false;
    }
  }
}

/**
 * Detect input nodes where we should not listen for events.
 *
 * Credit: github.com
 */
function isFormField(element) {
  if (!(element instanceof HTMLElement)) {
    return false;
  }

  const name = element.nodeName.toLowerCase();
  const type = (element.getAttribute("type") || "").toLowerCase();
  return (
    name === "select" ||
    name === "textarea" ||
    name === "trix-editor" ||
    (name === "input" &&
      type !== "submit" &&
      type !== "reset" &&
      type !== "checkbox" &&
      type !== "radio" &&
      type !== "file") ||
    element.isContentEditable
  );
}
