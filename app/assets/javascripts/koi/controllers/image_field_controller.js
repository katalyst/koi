import {Controller} from "@hotwired/stimulus";

export default class ImageFieldController extends Controller {
  static targets = ["preview", "destroyImage"];
  static values = {
    mimeTypes: Array,
  };

  #counter = 0;
  #initialImageSrc;
  #onUploadFlag = false;

  connect() {
    this.#initialImageSrc = this.imageTag.getAttribute("src");
  }

  onUpload(event) {
    this.#onUploadFlag = true;

    // Set the image to be destroyed only if it is already persisted
    if (this.hasDestroyImageTarget) {
      this.destroyImageTarget.value = false;
    }
    this.previewTarget.classList.remove("hidden");

    // Show preview only if a file has been selected in the file picker popup. If cancelled, show previous file or do
    // not show preview at all
    if (event.currentTarget.files.length > 0) {
      this.showPreview(event.currentTarget.files[0]);
    } else {
      this.imageTag.src = this.#initialImageSrc;
    }
  }

  setDestroy(event) {
    event.preventDefault();

    // If an image is already persisted and another image has been picked from the file picker popup, but the new image
    // is removed, show the original image
    if (this.#initialImageSrc && this.#onUploadFlag) {
      this.#onUploadFlag = false;
      this.imageTag.src = this.#initialImageSrc;
    } else {
      // Set image to be destroyed, hide preview and remove image url
      if (this.hasDestroyImageTarget) {
        this.destroyImageTarget.value = true;
      }
      this.previewTarget.classList.add("hidden");
      this.imageTag.src = "";
    }

    this.fileInput.value = "";
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

  showPreview(file) {
    const reader = new FileReader();

    reader.onload = (e) => {
      this.imageTag.src = e.target.result;
    };
    reader.readAsDataURL(file);
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
