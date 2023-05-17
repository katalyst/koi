# frozen_string_literal: true

namespace :yarn do
  desc "Install npm packages with yarn"
  task install: :environment do
    sh "yarn install"
  end

  desc "Lint JS/SCSS files using yarn (prettier)"
  task lint: :install do
    sh "yarn lint"
  end

  desc "Autoformat JS/SCSS files using yarn (prettier)"
  task format: :install do
    sh "yarn format"
  end
end
