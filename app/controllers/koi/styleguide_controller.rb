# frozen_string_literal: true

module Koi
  class StyleguideController < ApplicationController
    helper "koi/styleguide"

    def show
      render action: params[:template]
    end
  end
end
