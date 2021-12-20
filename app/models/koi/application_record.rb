# frozen_string_literal: true

module Koi
  class ApplicationRecord < ActiveRecord::Base
    include Koi::Model

    self.abstract_class = true
  end
end
