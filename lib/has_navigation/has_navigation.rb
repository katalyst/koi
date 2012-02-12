require_relative 'has_navigation/has_navigation'
ActiveRecord::Base.send :extend, HasNavigation
