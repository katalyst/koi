# frozen_string_literal: true

module Koi
  module AssetsHelper
    def is_resource?
      !is_collection?
    end

    def is_collection?
      resource.data.nil?
    end
  end
end
