class <%= class_name %> < ActiveRecord::Base

<%- if @orderable -%>
  has_crud :orderable => true<%= @versioned ? ", :versioned => true" : "" %>
<%- else -%>
  has_crud<%= @versioned ? " :versioned => true" : "" %>
<%- end -%>

<%- model_attributes.each do |attr| -%>
  <%= make_field_config(attr) -%>
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
