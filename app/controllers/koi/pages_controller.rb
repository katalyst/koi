module Koi
  class PagesController < AdminCrudController
    defaults :route_prefix => ''

    def is_settable?
      true
    end
  end
end
