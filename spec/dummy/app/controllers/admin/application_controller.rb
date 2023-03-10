# frozen_string_literal: true

module Admin
  class ApplicationController < Koi::ApplicationController
    helper Koi::DefinitionListHelper

    authenticate_local_admins Rails.env.development?

    def sort_and_paginate(records)
      @sort, records = table_sort(records)
      @pagy, records = pagy(records)
      records
    end
  end
end
