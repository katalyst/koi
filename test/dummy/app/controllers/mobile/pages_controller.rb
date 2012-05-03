module Mobile
  class PagesController < Mobile::ApplicationController
    def show
      super
      # redirect_to root_path unless @page.is_mobile?
    end
  end
end
