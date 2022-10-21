import { Controller } from "@hotwired/stimulus";

export default class FileFieldController extends Controller {
  static targets = ["preview", "destroy"];
  static values = {
    mimeTypes: Array,
  };

  connect() {
    this.counter = 0;
    this.initialPreviewContent = null;
    this.onUploadFlag = false;
  }

  onUpload(event) {
    this.onUploadFlag = true;

    // Set the file to be destroyed only if it is already persisted
    if (this.hasDestroyTarget) {
      this.destroyTarget.value = false;
    }
    this.previewTarget.classList.remove("hidden");

    // Show preview only if a file has been selected in the file picker popup. If cancelled, show previous file or do
    // not show preview at all
    if (this.hasPreviewTarget) {
      if (event.currentTarget.files.length > 0) {
        this.showPreview(event.currentTarget.files[0]);
      } else {
        this.setPreviewContent(this.initialPreviewContent);
      }
    }
  }

  setDestroy(event) {
    event.preventDefault();

    // If the data is already persisted and another image has been picked from the file picker popup, but the new image
    // is removed, show the original image
    if (this.initialPreviewContent && this.onUploadFlag) {
      this.onUploadFlag = false;
      this.setPreviewContent(this.initialPreviewContent);
    } else {
      // Set image to be destroyed, hide preview and remove image url
      if (this.hasDestroyTarget) {
        this.destroyTarget.value = true;
      }
      if (this.hasPreviewTarget) {
        this.previewTarget.classList.add("hidden");
        this.setPreviewContent("");
      }
    }

    this.fileInput.value = "";
  }

  setPreviewContent(content) {
    if (this.filenameTag) {
      this.filenameTag.innerText = text;
    }
  }

  drop(event) {
    event.preventDefault();

    const file = this.fileForEvent(event, this.mimeTypesValue);
    if (file) {
      const dT = new DataTransfer();
      dT.items.add(file);
      this.fileInput.files = dT.files;
      this.fileInput.dispatchEvent(new Event("change"));
    }

    this.counter = 0;
    this.element.classList.remove("droppable");
  }

  dragover(event) {
    event.preventDefault();
  }

  dragenter(event) {
    event.preventDefault();

    if (this.counter === 0) {
      this.element.classList.add("droppable");
    }
    this.counter++;
  }

  dragleave(event) {
    event.preventDefault();

    this.counter--;
    if (this.counter === 0) {
      this.element.classList.remove("droppable");
    }
  }

  get fileInput() {
    return this.element.querySelector("input[type='file']");
  }

  get filenameTag() {
    if (!this.hasPreviewTarget) return null;

    return this.previewTarget.querySelector("p.preview-filename");
  }

  showPreview(file) {
    const reader = new FileReader();

    reader.onload = (e) => {
      if (this.filenameTag) {
        this.filenameTag.innerText = file.name;
      }
    };
    reader.readAsDataURL(file);
  }

  /**
   * Given a drop event, find the first acceptable file.
   * @param event {DropEvent}
   * @param mimeTypes {String[]}
   * @returns {File}
   */
  fileForEvent(event, mimeTypes) {
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
}
