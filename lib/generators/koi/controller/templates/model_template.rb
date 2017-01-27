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

end
