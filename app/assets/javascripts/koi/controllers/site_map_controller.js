import { Controller } from "@hotwired/stimulus";

export default class SiteMapController extends Controller {
  connect() {
    window.Ornament.C.Sitemap.init();
  }
}
