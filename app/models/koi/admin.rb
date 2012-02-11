module Koi
  class Admin < ActiveRecord::Base
      devise :database_authenticatable, :recoverable,
             :rememberable, :trackable, :validatable,
             :registerable, :stretches => 20
  end
end
