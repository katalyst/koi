# frozen_string_literal: true

module Koi
  class CrudController < ApplicationController
    include HasCrud::ActionController

    layout "application"
    has_crud
    defaults route_prefix: ""
  end
end
