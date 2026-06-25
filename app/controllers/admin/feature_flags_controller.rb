# frozen_string_literal: true

module Admin
  class FeatureFlagsController < ApplicationController
    before_action :set_feature_flag, only: %i[show update destroy]

    attr_reader :collection, :feature_flag

    def index
      @collection = Collection.with_params(params).apply(FeatureFlag.all)

      render locals: { collection: }
    end

    def show
      render locals: { feature_flag:, groups: Flipper.group_names }
    end

    def new
      @feature_flag = FeatureFlag.build

      render locals: { feature_flag: }
    end

    def create
      @feature_flag = FeatureFlag.build(key: params.expect(feature_flag: [:key]).fetch(:key, nil))

      if feature_flag.save
        redirect_to(admin_feature_flag_path(feature_flag), status: :see_other)
      else
        render(:new, locals: { feature_flag: }, status: :unprocessable_content)
      end
    end

    def update
      feature_flag.update(feature_flag_params)

      redirect_to(admin_feature_flags_path, status: :see_other)
    end

    def destroy
      feature_flag.destroy

      redirect_to(admin_feature_flags_path, status: :see_other)
    end

    private

    def set_feature_flag
      @feature_flag = FeatureFlag.find(params.expect(:key))
    end

    def feature_flag_params
      params.expect(feature_flag: [:state, :percentage_of_actors, :percentage_of_time, :actors, { groups: [] }])
    end

    class Collection < Katalyst::Tables::Collection::Array
      def model
        FeatureFlag
      end

      def model_name
        FeatureFlag.model_name
      end
    end
  end
end
