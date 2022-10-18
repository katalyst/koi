import { Application } from "@hotwired/stimulus";

// Stimulus controllers. This should ultimately be moved to koi/admin.js
import "@hotwired/turbo-rails";
import "@rails/actiontext";

const application = Application.start();

window.Stimulus = application;

export { application };
