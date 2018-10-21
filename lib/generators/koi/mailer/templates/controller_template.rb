class <%= plural_class_name %>Controller < CrudController

  def index
    redirect_to action: :new
  end

  def create
    <%- unless @skip_recaptcha -%>
      @<%= singular_name %> = <%= class_name %>.new(permitted_params[:<%= singular_name %>])

      unless verify_recaptcha(model: @<%= singular_name %>, message: I18n.t('captcha.failed_message'))
        return render :action => 'new'
      end
    <%- end -%>

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

  private

  <%= make_permitted_params %>

end
