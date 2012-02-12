module Koi
  class AdminCrudController < Koi::ApplicationController
    has_crud :admin => true
    defaults :route_prefix => 'admin'
  end
end
