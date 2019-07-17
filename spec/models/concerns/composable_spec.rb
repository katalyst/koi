require "rails_helper"

RSpec.describe Composable, type: :model do
  subject { Page.new(body: body_data) }
  let(:body_data) { [{ foo: 1 }] }
  let(:empty) { Page.new }
  let(:body_compontents) {
    [:section, :heading, :text, :rich_text, :autocompletes, :hero, :hero_list, :text_with_image, :repeatable_thing,
     :no_config, :kitchen_sink]
  }

  describe ".composable" do
    it { expect(Page._composable).to include(body: { components: body_compontents }) }
  end

  describe ".composable?" do
    it { expect(Page.composable?(:title)).to be false }
    it { expect(Page.composable?(:body)).to be true }
    it { expect(Page.composable?(:missing)).to be false }
  end

  describe ".composable_crud_config" do
    it { expect(Page.composable_components(:title)).to be_nil }
    it { expect(Page.composable_components(:body)).to eq body_compontents }
  end

  describe "#composable?" do
    it { expect(subject.composable?(:body)).to be true }
    it { expect(empty.composable?(:body)).to be false }
  end

  describe "#composable_sections" do
    context "only text" do
      let(:body_data) { [{ component_type: "text", content: "Content" }] }
      it "should add a wrapper section" do
        expect(subject.composable_sections(:body))
          .to eq [
                   { section_type: "body", section_data: [{ component_type: "text", content: "Content" }] },
                 ].as_json
      end
    end

    context "draft text" do
      let(:body_data) { [{ component_type: "text", content: "Content", component_draft: true }] }
      it "should remove draft content" do
        expect(subject.composable_sections(:body)).to eq []
      end

      it "should mark draft content" do
        expect(subject.composable_sections(:body, include_drafts: true))
          .to eq [
                   {
                     section_type: "body",
                     section_data: [{ component_type: "text", content: "Content", component_draft: true }],
                   }
                 ].as_json
      end
    end

    context "mixed text" do
      let(:body_data) { [{ component_type: "text", content: "Draft", component_draft: true },
                         { component_type: "text", content: "Content" }] }

      it "should remove draft content" do
        expect(subject.composable_sections(:body))
          .to eq [
                   { section_type: "body", section_data: [{ component_type: "text", content: "Content" }] }
                 ].as_json
      end

      it "should mark draft content" do
        expect(subject.composable_sections(:body, include_drafts: true))
          .to eq [
                   {
                     section_type: "body",
                     section_data: [{ component_type: "text", content: "Draft", component_draft: true },
                                    { component_type: "text", content: "Content" }] }
                 ].as_json
      end
    end

    context "section" do
      let(:body_data) { [{ component_type: "section", data: { section_type: "div" } },
                         { component_type: "text", content: "Content" }] }
      it "should move content into section" do
        expect(subject.composable_sections(:body))
          .to eq [
                   {
                     section_type:  "div",
                     section_data:  [{ component_type: "text", content: "Content" }],
                     section_draft: false,
                     advanced:      {},
                   }
                 ].as_json
      end
    end

    context "draft section" do
      let(:body_data) { [{ component_type: "section", component_draft: true },
                         { component_type: "text", content: "Content" }] }
      it "should remove draft section and text" do
        expect(subject.composable_sections(:body)).to eq []
      end

      it "should mark draft section and text as draft" do
        expect(subject.composable_sections(:body, include_drafts: true))
          .to eq [
                   { section_type:  "body",
                     section_data:  [{ component_type: "text", content: "Content", component_draft: true }],
                     section_draft: true,
                     advanced:      {}
                   }
                 ].as_json
      end
    end
  end
end
