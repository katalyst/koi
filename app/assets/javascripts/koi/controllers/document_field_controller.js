import FileFieldController from "./file_field_controller";

export default class DocumentFieldController extends FileFieldController {
  connect() {
    this.initialPreviewContent = this.filenameTag.text;
  }

  setPreviewContent(content) {
    this.filenameTag.innerText = content;
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

  get filenameTag() {
    return this.previewTarget.querySelector("p.preview-filename");
  }
}
