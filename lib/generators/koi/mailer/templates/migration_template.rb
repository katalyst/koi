class Create<%= class_name.pluralize.delete('::') %> < ActiveRecord::Migration
  def change
    create_table :<%= table_name %> do |t|
<%- model_attributes.each do |attribute| -%>
      t.<%= attribute.type %> :<%= attribute.name %>
<%- end -%>
<%- if @versioned -%>
      t.string :aasm_state
<%- end -%>
<%- if @orderable -%>
      t.integer :ordinal
<%- end -%>
      # Friendly ID
      t.string  :slug
      t.timestamps
    end
    add_index :<%= table_name %>, :slug, :unique => true
  end
end

