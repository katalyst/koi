# frozen_string_literal: true

class User < ApplicationRecord
  has_crud

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  crud.config do
    index fields: %i[email last_sign_in_ip]
  end
end
