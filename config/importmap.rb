# frozen_string_literal: true

pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@github/webauthn-json/browser-ponyfill", to: "https://ga.jspm.io/npm:@github/webauthn-json@2.1.1/dist/esm/webauthn-json.browser-ponyfill.js"
pin "@popperjs/core", to: "https://ga.jspm.io/npm:@popperjs/core@2.11.8/lib/index.js", preload: false
pin "@rails/actiontext", to: "actiontext.js", preload: false
pin "trix", preload: false

pin_all_from Koi::Engine.root.join("app/assets/javascripts/koi"), under: "koi"
