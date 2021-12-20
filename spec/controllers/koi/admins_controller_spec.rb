# frozen_string_literal: true

require "rails_helper"

RSpec.describe Koi::AdminsController, type: :controller do
  it { expect(controller).to have_attributes(index_title: "All Admins") }
  it { expect(controller).to have_attributes(new_title: "Add Admin") }
  it { expect(controller).to have_attributes(action_csv_title: "Download CSV") }

  context "with resource" do
    let(:admin) { create :admin }

    before { controller.instance_variable_set(:@admin, admin) }

    it { expect(controller).to have_attributes(edit_title: "Edit #{admin}") }
  end
end
