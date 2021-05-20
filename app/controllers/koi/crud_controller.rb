module Koi
  class CrudController < ActionController::Base
    include HasCrud::ActionController

    layout 'application'
    has_crud
    defaults :route_prefix => ''
  end
end
