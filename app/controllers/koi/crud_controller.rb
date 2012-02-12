module Koi
  class CrudController < ActionController::Base
    layout 'application'
    has_crud
    defaults :route_prefix => ''
  end
end
