module Koi
  class AdminCrudController < ApplicationController
    helper :all
    has_crud :admin => true
    defaults :route_prefix => 'admin'
  end
end
