class Admin::SettingsController < Admin::KoiCrudController
  respond_to :html, :js

  def create
    create! do |success, failure|
      success.html { redirect_to :back }
      success.js
      failure.js
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to :back }
      success.js
      failure.js
    end
  end
end

