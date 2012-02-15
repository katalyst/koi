class <%= class_name %> < ActiveRecord::Base
<%- if @orderable -%>
  has_crud :orderable => true<%= @versioned ? ", :versioned => true" : "" %>
<%- else -%>
  has_crud<%= @versioned ? " :versioned => true" : "" %>
<%- end -%>
end

