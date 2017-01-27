class <%= class_name %> < ApplicationRecord

  has_crud settings: true

  <%= render_enums %>
  <%= render_associations %>
  <%= render_images %>
  <%= render_files %>
  <%= render_urls %>
  <%= render_booleans %>
  crud.config do
    config :admin do
      exportable true
      actions only:  [:index, :show]
      index fields: <%= crud_field_list %>,
            order:  { created_at: :desc }
      csv  fields: <%= crud_csv_field_list %>
    end
  end

end
