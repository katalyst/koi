module Koi
  class CrudController <  ActionController::Base
    has_crud
    defaults :route_prefix => ''
  end
end
