# frozen_string_literal: true

module Koi
  module Model
    extend ActiveSupport::Concern

    included do
      include Exportable
      include HasSettings
      include HasNavigation
      include HasCrud::ActiveRecord
    end
  end
end
