# frozen_string_literal: true

module Admin
  module ActiveStorage
    class DirectUploadsController < ::ActiveStorage::DirectUploadsController
      include Koi::Controller
    end
  end
end
