class <%= class_name %> < ActiveRecord::Base

<%- if @orderable -%>
  has_crud :orderable => true<%= @versioned ? ", :versioned => true" : "" %>
<%- else -%>
  has_crud<%= @versioned ? " :versioned => true" : "" %>
<%- end -%>

<%- model_attributes.each do |attr| -%>
    <%- if field_is_enum?(attr.name, attr.type) -%>
  <%= "#{attr.name.pluralize.upcase} = { active: 'Active', inactive: 'Inactive' }\n" -%>
  <%= "enum #{attr.name}: #{attr.name.pluralize.upcase}.keys\n" -%>
  <%= "validates :#{attr.name}, presence: true\n\n" -%>
    <%- end -%>
    <%- if field_is_image?(attr.name, attr.type) -%>
  <%= "dragonfly_accessor :#{attr.name.chomp('_uid')}, app: :image\n" -%>
  <%= "validates_property :format, of: :#{attr.name.chomp('_uid')}, in: ['jpeg', 'png', 'gif', 'png']\n\n" -%>
    <%- end -%>
    <%- if field_is_file?(attr.name, attr.type) -%>
  <%= "dragonfly_accessor :#{attr.name.chomp('_uid')}, app: :file\n" -%>
  <%= "validates_property :ext, of: :#{attr.name.chomp('_uid')}, in: ['pdf', 'doc', 'docx', 'csv', 'txt']\n\n" -%>
    <%- end -%>
<%- end -%>

  crud.config do
    fields <%- model_attributes.each_with_index do |attr, i| -%>
  <%= make_field_type(attr, i) -%>
  <%- end -%>

    config :admin do
      exportable true
      actions only:  [:index, :show, :new, :edit]
      index fields: <%= crud_field_list %>,
            order:  { created_at: :desc }
      form  fields: <%= crud_field_list %>
      csv   fields: <%= crud_csv_field_list %>
    end
  end

end
