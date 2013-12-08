class <%= plural_class_name %>Controller < CrudController

  def index
    redirect_to action: :new
  end

  def create
    create! do |success, failure|
      success.html do
      <%- if @skip_sidekiq -%>
        <%= class_name %>Mailer.<%= singular_name %>_created(@<%= singular_name %>.id).deliver
      <%- else -%>
        <%= class_name %>Mailer.delay_for(10.seconds).<%= singular_name %>_created(@<%= singular_name %>.id)
      <%- end -%>
        redirect_to thanks_<%= plural_name %>_path
      end
    end
  end

end
