const DEFAULT_DELAY = 250;

/**
 * A utility class for managing CSS transition animations.
 *
 * Transition uses Javascript timers to track state instead of relying on
 * CSS transition events, which is a more complicated API. Please call `cancel`
 * when the node being animated is detached from the DOM to avoid unexpected
 * errors or animation glitches.
 *
 * Transition assumes that CSS already specifies styles to achieve the expected
 * start and end states. Transition adds temporary overrides and then animates
 * between those values using CSS transitions. For example, to use the collapse
 * transition:
 *
 * @example
 *   // CSS:
 *   target {
 *     max-height: unset;
 *     overflow: 0;
 *   }
 *   target.hidden {
 *     max-height: 0;
 *   }
 *
 * @example
 *   // Javascript
 *   target.addClass("hidden");
 *   new Transition(target).collapse().start();
 */
class Transition {
  constructor(target, options) {
    const { delay } = this._setDefaults(options);

    this.target = target;
    this.runner = new Runner(this, delay);
    this.properties = [];

    this.startingCallbacks = [];
    this.startedCallbacks = [];
    this.completeCallbacks = [];
  }

  add(property) {
    this.properties.push(property);
    return this;
  }

  /** Adds callback for transition events */
  addCallback(type, callback) {
    switch (type) {
      case "starting":
        this.startingCallbacks.push(callback);
        break;
      case "started":
        this.startedCallbacks.push(callback);
        break;
      case "complete":
        this.completeCallbacks.push(callback);
        break;
    }
    return this;
  }

  /** Collapse an element in place, assumes overflow is set appropriately, margin is not collapsed */
  collapse() {
    return this.add(
      new PropertyTransition(
        "max-height",
        `${this.target.scrollHeight}px`,
        "0px",
      ),
    );
  }

  /** Restore a collapsed element */
  expand() {
    return this.add(
      new PropertyTransition(
        "max-height",
        "0px",
        `${this.target.scrollHeight}px`,
      ),
    );
  }

  /** Slide an element left or right by its scroll width, assumes position relative */
  slideOut(direction) {
    return this.add(
      new PropertyTransition(direction, "0px", `-${this.target.scrollWidth}px`),
    );
  }

  /** Restore an element that has been slid */
  slideIn(direction) {
    return this.add(
      new PropertyTransition(direction, `-${this.target.scrollWidth}px`, "0px"),
    );
  }

  /** Cause an element to become transparent by transforming opacity */
  fadeOut() {
    return this.add(new PropertyTransition("opacity", "100%", "0%"));
  }

  /** Cause a transparent element to become visible again */
  fadeIn() {
    return this.add(new PropertyTransition("opacity", "0%", "100%"));
  }

  start(callback = null) {
    // start the runner on next tick so that any side-effects of the current execution can occur first
    requestAnimationFrame(() => {
      this.runner.start(this.target);
      if (callback) callback();
    });
    return this;
  }

  cancel() {
    this.runner.stop(this.target);
    return this;
  }

  _starting() {
    const event = new Event("transition:starting");
    this.startingCallbacks.forEach((cb) => cb(event));
    this.target.dispatchEvent(event);
  }

  _started() {
    const event = new Event("transition:started");
    this.startedCallbacks.forEach((cb) => cb(event));
    this.target.dispatchEvent(event);
  }

  _complete() {
    const event = new Event("transition:complete");
    this.completeCallbacks.forEach((cb) => cb(event));
    this.target.dispatchEvent(event);
  }

  _setDefaults(options) {
    return Object.assign({ delay: DEFAULT_DELAY }, options);
  }
}

/**
 * Encapsulates internal execution and timing functionality for `Transition`
 */
class Runner {
  constructor(transition, delay) {
    this.transition = transition;
    this.running = null;
    this.delay = delay;
  }

  start(target) {
    // 1. Set the initial state(s)
    this.transition.properties.forEach((t) => t.onStarting(target));

    // 2. On next update, set transition and final state(s)
    requestAnimationFrame(() => this.onStarted(target));

    // 3. After transition has finished, clean up
    this.running = setTimeout(() => this.stop(target, true), this.delay);

    this.transition._starting();
  }

  onStarted(target) {
    target.style.transitionProperty = this.transition.properties
      .map((t) => t.property)
      .join(",");
    target.style.transitionDuration = `${this.delay}ms`;
    this.transition.properties.forEach((t) => t.onStarted(target));

    this.transition._started();
  }

  stop(target, timeout = false) {
    if (!this.running) return;
    if (!timeout) clearTimeout(this.running);

    this.running = null;

    target.style.removeProperty("transition-property");
    target.style.removeProperty("transition-duration");
    this.transition.properties.forEach((t) => t.onComplete(target));

    this.transition._complete();
  }
}

/**
 * Represents animation of a single CSS property. Currently only CSS animations
 * are supported, but this could be a natural extension point for Javascript
 * animations in the future.
 */
class PropertyTransition {
  constructor(property, from, to) {
    this.property = property;
    this.from = from;
    this.to = to;
  }

  onStarting(target) {
    target.style.setProperty(this.property, this.from);
  }

  onStarted(target) {
    target.style.setProperty(this.property, this.to);
  }

  onComplete(target) {
    target.style.removeProperty(this.property);
  }
}

export { Transition };
