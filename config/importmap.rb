# frozen_string_literal: true

pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true

pin "govuk-frontend", to: "https://ga.jspm.io/npm:govuk-frontend@4.3.1/govuk-esm/all.mjs"

pin_all_from Koi::Engine.root.join("app/assets/javascripts/koi/controllers"),
             under: "koi/controllers", preload: Rails.env.test?
