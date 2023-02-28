# frozen_string_literal: true

pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true

pin_all_from Koi::Engine.root.join("app/assets/javascripts/koi"),
             under: "koi", preload: Rails.env.test?
