# frozen_string_literal: true

class AddPrincipalToAdminDeviceAuthorizations < ActiveRecord::Migration[8.0]
  def change
    add_column :admin_device_authorizations, :principal, :text
  end
end
