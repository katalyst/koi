class <%= plural_class_name %>Controller < CrudController

  private
    def permitted_params
      params.permit(<%= "#{class_name.downcase}: #{crud_field_list + file_and_image_params}" %>)
    end
end
