class <%= class_name.delete('::') %>Serializer < ActiveModel::Serializer
<%- if model_attributes.empty? -%>
  attributes :id
<%- else -%>
  attributes :id, <%= model_attributes.collect { |a| ":#{a.name}" }.join(', ') %>
<%- end -%>
end
