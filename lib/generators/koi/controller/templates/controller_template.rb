class <%= plural_class_name %>Controller < CrudController

  private

  <%= make_permitted_params %>
  
end
