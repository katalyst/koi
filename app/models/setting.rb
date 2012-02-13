class Setting < ActiveRecord::Base
  belongs_to :set, :polymorphic => true
  has_crud ajaxable: true
end
