# frozen_string_literal: true

require "rails_helper"

def transform_tree(nodes, &block)
  output = []
  nodes.each do |node|
    output << yield(node)
    output << transform_tree(node.children, &block) if node.children.any?
  end
  output
end

RSpec.describe NavigationMenu do
  subject(:menu) { create :navigation_menu, navigation_links: links }

  let(:first) { build :navigation_link, title: "First", url: "/first" }
  let(:last) { build :navigation_link, title: "Last", url: "/last" }
  let(:links) { [first, last] }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:slug) }
  it { is_expected.to validate_uniqueness_of(:slug).ignoring_case_sensitivity }

  it { expect(menu.navigation_links).to eq(links) }

  it { is_expected.to have_attributes(state: :published) }
  it { expect(menu.latest_version).to eq(menu.current_version) }
  it { expect(menu.current_items.as_json).to eq([{ id: first.id, depth: 0 }.as_json,
                                                 { id: last.id, depth: 0 }.as_json]) }
  it { expect(menu.current_navigation_links).to eq(links) }
  it { expect(menu.current_tree).to eq(links) }

  describe "#destroy" do
    before { menu }

    it "deletes versions" do
      expect { menu.destroy! }.to change(NavigationMenu::Version, :count).to(0)
    end

    it "deletes links" do
      expect { menu.destroy! }.to change(NavigationLink, :count).to(0)
    end
  end

  shared_examples "an un-versioned change" do
    it "does not change state" do
      expect { update }.not_to change(menu, :state)
    end

    it "does not change versions" do
      expect { update }.not_to change(menu, :latest_version)
    end
  end

  describe "#title=" do
    let(:update) { menu.update(title: "Updated") }

    it_behaves_like "an un-versioned change"

    it { expect { update }.to change(menu, :title) }
  end

  describe "#slug=" do
    let(:update) { menu.update(slug: "updated") }

    it_behaves_like "an un-versioned change"

    it { expect { update }.to change(menu, :slug) }
  end

  shared_examples "a versioned change" do
    it "changes state" do
      expect { update }.to change(menu, :state).from(:published).to(:draft)
    end

    it "creates a new version" do
      expect { update }.to change(menu, :latest_version)
    end

    it "does not publish the new version" do
      expect { update }.not_to change(menu, :current_version)
    end
  end

  describe "add link" do
    let(:update) do
      update = create :navigation_link, navigation_menu: menu, title: "Update", url: "/update"
      menu.update(navigation_links_attributes: menu.latest_items + [{ id: update.id }])
    end

    it_behaves_like "a versioned change"

    it "adds item" do
      expect { update }.to change { transform_tree(menu.reload.latest_tree, &:url) }
                             .from(%w[/first /last])
                             .to(%w[/first /last /update])
    end

    context "with controller formatted attributes" do
      let(:update) do
        update     = create :navigation_link, navigation_menu: menu, title: "Update", url: "/update"
        attributes = { "0" => { id: first.id.to_s, index: "0", depth: "0" },
                       "1" => { id: update.id.to_s, index: "2", depth: "0" },
                       "2" => { id: last.id.to_s, index: "1", depth: "0" } }
        menu.update(navigation_links_attributes: attributes)
      end

      it "adds item" do
        expect { update }.to change { transform_tree(menu.reload.latest_tree, &:url) }
                               .from(%w[/first /last])
                               .to(%w[/first /last /update])
      end
    end
  end

  describe "remove link" do
    let(:update) do
      menu.update(navigation_links_attributes: menu.latest_items.take(1))
    end

    it_behaves_like "a versioned change"

    it "removes item" do
      expect { update }.to change { transform_tree(menu.reload.latest_tree, &:url) }
                             .from(%w[/first /last])
                             .to(%w[/first])
    end
  end

  describe "swap two links" do
    let(:update) do
      update = create :navigation_link, navigation_menu: menu, title: "Update", url: "/update"
      menu.update(navigation_links_attributes: [{ id: first.id },
                                                { id: update.id }])
    end

    it_behaves_like "a versioned change"

    it "changes item" do
      expect { update }.to change { transform_tree(menu.reload.latest_tree, &:url) }
                             .from(%w[/first /last])
                             .to(%w[/first /update])
    end
  end

  describe "reorder links" do
    let(:update) do
      menu.update(navigation_links_attributes: [{ id: last.id },
                                                { id: first.id }])
    end

    it_behaves_like "a versioned change"

    it "changes order" do
      expect { update }.to change { transform_tree(menu.reload.latest_tree, &:url) }
                             .from(%w[/first /last])
                             .to(%w[/last /first])
    end
  end

  describe "change depth" do
    let(:update) do
      menu.update(navigation_links_attributes: [{ id: first.id, depth: 0 },
                                                { id: last.id, depth: 1 }])
    end

    it_behaves_like "a versioned change"

    it "changes nesting" do
      expect { update }.to change { transform_tree(menu.reload.latest_tree, &:url) }
                             .from(%w[/first /last])
                             .to(["/first", ["/last"]])
    end
  end

  describe "#publish!" do
    let(:link_attributes) { menu.latest_items.take(1) }

    before do
      menu.update(navigation_links_attributes: link_attributes)
    end

    it "changes current version" do
      current = menu.current_version
      latest  = menu.latest_version
      expect { menu.publish! }.to change(menu, :current_version).from(current).to(latest)
    end

    it "removes orphaned version" do
      expect { menu.publish! }.to change(NavigationMenu::Version, :count).by(-1)
    end

    it "removes orphaned links" do
      expect { menu.publish! }.to change(NavigationLink, :count).by(-1)
    end

    it "removes orphaned current version" do
      current = menu.current_version
      menu.publish!
      expect(NavigationMenu::Version.find_by(id: current.id)).to be_nil
    end

    it "removes orphaned current version link" do
      link_id = menu.current_items.map(&:id) - menu.latest_items.map(&:id)
      menu.publish!
      expect(NavigationLink.find_by(id: link_id.first)).to be_nil
    end
  end

  describe "#revert!" do
    let(:link_attributes) { menu.latest_items.take(1) }

    before do
      menu.update(navigation_links_attributes: link_attributes)
    end

    it "changes latest version" do
      current = menu.current_version
      latest  = menu.latest_version
      expect { menu.revert! }.to change(menu, :latest_version).from(latest).to(current)
    end

    it "removes orphaned version" do
      expect { menu.revert! }.to change(NavigationMenu::Version, :count).by(-1)
    end

    it "removes orphaned latest version" do
      latest = menu.latest_version
      menu.revert!
      expect(NavigationMenu::Version.find_by(id: latest.id)).to be_nil
    end

    it "does not remove links" do
      expect { menu.revert! }.to change(NavigationLink, :count).by(0)
    end

    context "when link itself is changed" do
      let(:updated_first) { create :navigation_link, title: "Updated First", url: first.url, navigation_menu: menu }
      let(:link_attributes) { [{ id: updated_first.id, depth: 0 }, { id: last.id, depth: 1 }] }

      it "removes orphaned version" do
        expect { menu.revert! }.to change(NavigationMenu::Version, :count).by(-1)
      end

      it "removes orphaned links" do
        expect { menu.revert! }.to change(NavigationLink, :count).by(-1)
      end
      
      it "removes orphaned latest version link" do
        menu.revert!
        expect(NavigationLink.find_by(id: updated_first.id)).to be_nil
      end
    end
  end
end
