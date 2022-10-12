import { Controller } from "@hotwired/stimulus";

export default class ImageFieldController extends Controller {
  static targets = ["preview"];
  static values = {
    mimeTypes: Array,
  };

  #counter = 0;

  onUpload(event) {
    this.previewTarget.classList.remove("hidden");

    const reader = new FileReader();

    reader.onload = (e) => {
      this.imageTag.src = e.target.result;
    };

    reader.readAsDataURL(event.currentTarget.files[0]);
  }

  drop(event) {
    event.preventDefault();

    const file = fileForEvent(event, this.mimeTypesValue);
    if (file) {
      const dT = new DataTransfer();
      dT.items.add(file);
      this.fileInput.files = dT.files;
      this.fileInput.dispatchEvent(new Event("change"));
    }

    this.#counter = 0;
    this.element.classList.remove("droppable");
  }

  dragover(event) {
    event.preventDefault();
  }

  dragenter(event) {
    event.preventDefault();

    if (this.#counter === 0) {
      this.element.classList.add("droppable");
    }
    this.#counter++;
  }

  dragleave(event) {
    event.preventDefault();

    this.#counter--;
    if (this.#counter === 0) {
      this.element.classList.remove("droppable");
    }
  }

  get fileInput() {
    return this.element.querySelector("input[type='file']");
  }

  get imageTag() {
    return this.previewTarget.querySelector("img");
  }
}

/**
 * Given a drop event, find the first acceptable file.
 * @param event {DropEvent}
 * @param mimeTypes {String[]}
 * @returns {File}
 */
function fileForEvent(event, mimeTypes) {
  const accept = (file) => mimeTypes.indexOf(file.type) > -1;

  let file;

  if (event.dataTransfer.items) {
    const item = [...event.dataTransfer.items].find(accept);
    if (item) {
      file = item.getAsFile();
    }
  } else {
    file = [...event.dataTransfer.files].find(accept);
  }

  return file;
}
