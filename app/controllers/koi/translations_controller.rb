module Koi
  class TranslationsController < AdminCrudController
    defaults :route_prefix => ''

  protected

    def collection
      @translations ||= (current_admin.god? ?
        end_of_association_chain.all : end_of_association_chain.admin)
    end
  end
end
