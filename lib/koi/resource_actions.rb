module Koi
  module ResourceActions
    def index
      component_name = (self.class::IndexOptions[:as] || :table).to_s.titleize
      component = "Koi::Components::IndexAs#{component_name}".constantize

      html = component.new(collection, &self.class::Index)

      render inline: html.html_safe, layout: send(:_layout)
    end

    def new
      @form = Koi::FormProxy.new(self.class::Form)
      super()
    end

    def show
      redirect_to url_for([:admin, resource_collection_name])
    end

    protected

    def permitted_params
      params.permit(resource_instance_name => self.class::PermittedParams)
    end
  end
end
