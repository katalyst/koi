module Koi
  class Admin < ActiveRecord::Base
      devise :database_authenticatable, :recoverable,
             :rememberable, :trackable, :validatable,
             :stretches => 20
  end
end
