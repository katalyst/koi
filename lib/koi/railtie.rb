# lib/railtie.rb
require 'koi'
require 'rails'

module Koi
  class Railtie < Rails::Railtie
    railtie_name :koi

    rake_tasks do
      path = File.expand_path(__dir__)
      Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
    end
  end
end

