import {Controller} from "@hotwired/stimulus";

export default class Filter__FormController extends Controller {
  static targets = ["input", "sort", "inputs"];

  initialize() {
    // debounce search
    this.update = debounce(this, this.update);
  }

  addKey(key) {
    if (this.inputTarget.value !== "") {
      this.inputTarget.value += " ";
    }
    this.inputTarget.value += `${key}:`;
    this.inputTarget.focus();
  }

  addValue(value) {
    this.inputTarget.value += `"${value}"`;
    this.inputTarget.focus();
    this.update();
  }

  update() {
    this.inputsTarget.innerHTML = "";

    const parser = new Parser(this.inputTarget.value);
    Object.entries(parser.tagged).forEach(([key, value]) => {
      value.forEach(value => {
        this.inputsTarget.insertAdjacentHTML(
          "beforeend",
          `<input type="hidden" name="${key}[]" value="${value}">`,
        );
      });
    });
    if (parser.untagged.length > 0) {
      this.inputsTarget.insertAdjacentHTML(
        "beforeend",
        `<input type="hidden" name="query" value="${parser.untagged.join(" ")}">`,
      )
    }

    this.element.requestSubmit();
  }

  submit() {
    const shouldFocus = document.activeElement === this.inputTarget;

    if (this.inputTarget.value === "") {
      this.inputTarget.disabled = true;
    }
    if (this.sortTarget.value === "") {
      this.sortTarget.disabled = true;
    }

    // restore state and focus after submit
    Promise.resolve().then(() => {
      this.inputTarget.disabled = false;
      this.sortTarget.disabled = false;
      if (shouldFocus) {
        this.inputTarget.focus();
      }
    });
  }
}

function debounce(self, f) {
  let timer = null;
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => {
      f.apply(self, ...args);
    }, 300);
  };
}

class Parser {
  constructor(input) {
    this.tagged = {};
    this.untagged = [];
    this.input = input;

    while (this.input.length > 0) this.parse();
  }

  parse() {
    let _, key, value, token, rest;

    this.takeWhitespace() || this.takeTagged() || this.takeUntagged();
  }

  takeWhitespace() {
    const match = this.input.match(/^\s+(.*)$/);
    if (match) {
      const [_, rest] = match;
      this.input = rest;
      return true;
    }
  }

  takeTagged() {
    const match = this.input.match(/^(\w+):(?:"([^"]*)"|([^" ]\w+))(.*)/);
    if (match) {
      const [_, key, quoted, unquoted, rest] = match;
      if (this.tagged[key] === undefined) {
        this.tagged[key] = [];
      }
      this.tagged[key].push(quoted || unquoted);
      this.input = rest;
      return true;
    }
  }

  takeUntagged() {
    const match = this.input.match(/^(\S+)(.*)$/);
    if (match) {
      const [_, token, rest] = match;
      this.untagged.push(token);
      this.input = rest;
      return true;
    } else {
      // this is a bug, we should never fail to match
      console.warn("unhandled input", this.input);
      this.input = "";
      return false;
    }
  }
}
