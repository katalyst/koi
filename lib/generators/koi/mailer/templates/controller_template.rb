class <%= plural_class_name %>Controller < CrudController

  def index
    redirect_to action: :new
  end

  def create
    create! do |success, failure|
      success.html do
        <%= class_name %>Mailer.<%= singular_name %>_created(@<%= singular_name %>.id).deliver
        redirect_to thanks_<%= plural_name %>_path
      end
    end
  end

end
