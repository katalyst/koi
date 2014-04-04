class <%= class_name %> < ActiveRecord::Base

  has_crud settings: true

  crud.config do
    config :admin do
      actions only:  [:index, :show]
      index   order: { created_at: :desc }
    end
  end

end
