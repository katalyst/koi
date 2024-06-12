class KoiToolbarElement extends HTMLElement {
  constructor() {
    super();

    this.setAttribute("role", "toolbar");
  }
}

customElements.define("koi-toolbar", KoiToolbarElement);
