import FileFieldController from "koi/controllers/file_field_controller";

export default class ImageFieldController extends FileFieldController {
  connect() {
    this.initialPreviewContent = this.imageTag.getAttribute("src");
  }

  setPreviewContent(content) {
    this.imageTag.src = content;
  }

  showPreview(file) {
    const reader = new FileReader();

    reader.onload = (e) => {
      this.imageTag.src = e.target.result;
    };
    reader.readAsDataURL(file);
  }

  get imageTag() {
    return this.previewTarget.querySelector("img");
  }
}
