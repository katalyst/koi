# frozen_string_literal: true

require "rails_helper"

RSpec.describe Koi::Config do
  subject { crud }

  let(:crud) do
    crud = described_class.new
    crud.config do
      index title: "Index", fields: %i[id title]
      form new: "New Form", edit: "Edit Form",
           fields: %i[title description]
      config :admin do
        index title: "Admin Index"
      end
    end
    crud
  end

  describe "testing deeply nested namespaces" do
    let(:crud) { described_class.new(defaults: { admin: { form: { fields: [:title] } } }) }

    it "must respond with the default hash merged" do
      expect(crud.settings).to eq({
                                    admin:  {
                                      form:   {
                                        fields: [:title],
                                      },
                                      ignore: [],
                                    },
                                    ignore: [],
                                    map:    {},
                                    fields: {},
                                  })
    end

    it "must deep merge #config DSL settings" do
      crud.config do
        config :admin do
          form fields: [:description]
        end
      end

      expect(crud.settings).to eq({
                                    admin:  {
                                      form:   {
                                        fields: %i[title description],
                                      },
                                      ignore: [],
                                    },
                                    ignore: [],
                                    map:    {},
                                    fields: {},
                                  })
    end
  end

  describe "when asked about it type" do
    it "must respond with a hash" do
      expect(crud.settings).to be_kind_of Hash
    end
  end

  describe "when asked about it contents" do
    it "must respond with a content hash when no default is set" do
      expect(crud.settings).to eq({
                                    ignore: %i[id created_at updated_at cached_slug slug ordinal aasm_state],
                                    admin:  { ignore: %i[id created_at updated_at cached_slug slug ordinal
                                                         aasm_state], index: { title: "Admin Index" } },
                                    map:    {
                                      image_uid: :image,
                                      file_uid:  :file,
                                      data_uid:  :data,
                                    },
                                    fields: {
                                      description: { type: :text },
                                      image:       { type: :image },
                                      file:        { type: :file },
                                    },
                                    index:  { title: "Index", fields: %i[id title] },
                                    form:   { new: "New Form", edit: "Edit Form",
                                            fields: %i[title description] },
                                  })
    end

    it "must respond with a content hash containing default options when :defaults is set" do
      crud = described_class.new(defaults: { ignore: [:id] })
      crud.config do
        index title: "Index", fields: %i[id title]
        form new: "New Form", edit: "Edit Form",
             fields: %i[title description]
        config :admin do
          index title: "Admin Index"
        end
      end
      expect(crud.settings).to eq({
                                    ignore: [:id],
                                    index:  { title:  "Index",
                                              fields: %i[id title] },
                                    form:   { new:    "New Form",
                                              edit:   "Edit Form",
                                              fields: %i[title description] },
                                    map:    {},
                                    fields: {},
                                    admin:  { ignore: [],
                                              index:  {
                                                title: "Admin Index",
                                              } },
                                  })
    end
  end

  # rubocop:disable Performance/RedundantMerge
  describe "when merging another simple hash" do
    it "must respond with a merged hash" do
      crud.merge!({ index: { title: "Changed Title" } })
      expect(crud.settings[:index]).to eq({ title:  "Changed Title",
                                            fields: %i[id title] })
    end
  end

  describe "when merging another hash with arrays" do
    it "must respond with a merged hash" do
      crud.merge!({ index: { title:  "Changed Title",
                             fields: [:description] } })
      expect(crud.settings[:index]).to eq({ title:  "Changed Title",
                                            fields: %i[id title description] })
    end
  end

  describe "when merging another hash with arrays and strings" do
    it "must respond with a merged hash" do
      crud.merge!({ index: { title:  "Changed Title",
                             fields: %i[publish_date description created_at updated_at] } })
      expect(crud.settings[:index]).to eq({ title:  "Changed Title",
                                            fields: %i[id title publish_date description
                                                       created_at updated_at] })
    end
  end
  # rubocop:enable Performance/RedundantMerge

  describe "#find" do
    context "when asked about a value which is a proc" do
      before do
        crud.config do
          index title: proc { title }
        end
      end

      def title
        "Hello I am a Proc"
      end

      it "must respond by returning the stored proc" do
        proc_method = crud.find(:index, :title)
        result      = instance_eval(&proc_method)
        expect(result).to eq(title.to_s)
      end
    end

    context "when asked about an known nested hash key" do
      it "must respond with its value (Admin Index)" do
        expect(crud.find(:admin, :index, :title)).to eq("Admin Index")
      end

      it "must respond with its value (Index)" do
        expect(crud.find(:index, :title)).to eq "Index"
      end

      it "must respond with its value (Index) when given a default" do
        expect(crud.find(:index, :title, default: :miss)).to eq "Index"
      end
    end

    context "when asked about an unknown hash key" do
      it "must respond with a nil" do
        expect(crud.find(:unknown)).to be_nil
      end
    end

    context "when asked about an unknown hash key with a default" do
      it "must respond with default" do
        expect(crud.find(:unknown, default: :miss)).to eq :miss
      end
    end

    context "when asked about an unknown nested hash key" do
      it "must respond with a nil" do
        expect(crud.find(:something, :unknown)).to be_nil
      end
    end

    context "when asked about an unknown nested hash key with a default" do
      it "must respond with default" do
        expect(crud.find(:something, :unknown, default: :miss)).to eq :miss
      end
    end
  end
end
