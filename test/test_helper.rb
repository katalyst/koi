# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'rails/test_help'
require 'factory_girl'
require 'forgery'
require 'turn'
require 'pry'

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Loading factories
Dir["#{File.dirname(__FILE__)}/dummy/test/factories/**/*.rb"].each { |f| require f }
