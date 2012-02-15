require_relative 'has_crud/action_controller'
require_relative 'has_crud/active_record'

ActiveRecord::Base.send :include, HasCrud::ActiveRecord
ActionController::Base.send :include, HasCrud::ActionController
