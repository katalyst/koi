# frozen_string_literal: true

Koi.config.admin_stylesheet = "admin"

Rails.application.config.dartsass.builds = {
  "application.scss" => "application.css",
  "admin.scss"       => "admin.css",
}

Rails.application.config.dartsass.build_options << "--quiet-deps"
