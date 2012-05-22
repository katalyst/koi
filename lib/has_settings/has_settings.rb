require_relative 'has_settings/has_settings'
ActiveRecord::Base.send :extend, HasSettings
