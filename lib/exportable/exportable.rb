require_relative 'exportable/exportable'
require_relative 'exportable/exportable_controller'
ActiveRecord::Base.send :extend, Exportable
ActionController::Base.send :include, ExportableController
