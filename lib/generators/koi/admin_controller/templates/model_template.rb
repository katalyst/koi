class <%= class_name %> < ApplicationRecord
<%- if @orderable -%>
  has_crud :orderable => true<%= @versioned ? ", :versioned => true" : "" %>
<%- else -%>
  has_crud<%= @versioned ? " :versioned => true" : "" %>
<%- end -%>

<%= render_enums %>
<%= render_associations %>
<%= render_images %>
<%= render_files %>
<%= render_urls %>
<%= render_booleans %>
  crud.config do
    fields <%- model_attributes.each_with_index do |attr, i| -%>
  <%= make_field_type(attr, i) -%>
  <%- end -%>

    config :admin do
      actions only:  [:index, :show, :new, :edit]
      index fields: <%= crud_field_list %>,
            order:  { created_at: :desc }
      form  fields: <%= crud_field_list %>
      csv   fields: <%= crud_csv_field_list %>
    end
  end

end
