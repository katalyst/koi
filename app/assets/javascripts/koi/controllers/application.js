import { Application } from "@hotwired/stimulus"
import "@hotwired/turbo-rails"

const application = Application.start()

window.Stimulus = application

export { application }
