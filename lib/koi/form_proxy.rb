module Koi
  class FormProxy
    def initialize(form)
      @form = form
      @form_string = String.new
    end

    def render(builder)
      @builder = builder
      @form.call(self)
      @form_string.html_safe
    end

    def actions
      @form_string << @builder.submit
    end

    def method_missing(method_name, *args, &block)
      if @builder.respond_to?(method_name)
        @form_string << @builder.send(method_name, *args, &block)
      else
        super()
      end
    end
  end
end
