# frozen_string_literal: true

require "koi/extensions/object_rendering"

# Unit coverage for the workaround patched over
# ActionView::AbstractRenderer::ObjectRendering#merge_prefix_into_object_path.
# See https://github.com/rails/rails/issues/50916.
#
# +prefix+ is the controller's context prefix (e.g. "learning/quiz/questions")
# and +object_path+ is the rendered object's #to_partial_path
# (e.g. "courses/quiz/questions/question"). The method merges the two,
# de-duplicating an overlapping namespace so the partial resolves to the file
# nearest the controller.
RSpec.describe Koi::Extensions::ObjectRendering do
  subject(:merge) { renderer.merge_prefix_into_object_path(prefix, object_path) }

  let(:renderer) { Object.new.extend(described_class) }
  let(:object_path) { "courses/quiz/questions/question" }

  context "when the prefix has no namespace" do
    let(:prefix) { "learning/questions" }

    it "prepends the prefix namespace to the object path" do
      expect(merge).to eq("learning/courses/quiz/questions/question")
    end
  end

  context "when the whole prefix namespace overlaps the object namespace" do
    let(:prefix) { "courses/quiz/questions" }

    it "de-duplicates the shared namespace" do
      expect(merge).to eq("courses/quiz/questions/question")
    end
  end

  context "when a prefix segment collides with the object namespace at the same offset" do
    let(:prefix) { "learning/quiz/extra/questions" }

    # Regression: the previous implementation broke on the coincidental "quiz"
    # match and dropped the trailing "extra" segment.
    it "keeps the full prefix namespace when there is no true overlap" do
      expect(merge).to eq("learning/quiz/extra/courses/quiz/questions/question")
    end
  end

  context "when the overlap sits at a different offset in each path" do
    let(:prefix) { "learning/courses/quiz/questions" }

    # Regression: the previous implementation compared segments at the same
    # index and so missed the "courses/quiz" overlap, repeating it instead.
    it "de-duplicates the overlapping namespace" do
      expect(merge).to eq("learning/courses/quiz/questions/question")
    end
  end

  context "when a prefix segment is a string prefix of an object segment" do
    let(:prefix) { "admin/foo/things" }
    let(:object_path) { "foobar/things/thing" }

    # Regression: the previous implementation used String#start_with? and so
    # matched "foo" against "foobar".
    it "compares whole segments rather than partial strings" do
      expect(merge).to eq("admin/foo/foobar/things/thing")
    end
  end

  context "when the prefix has no directory separator" do
    let(:prefix) { "questions" }

    it "returns the object path unchanged" do
      expect(merge).to eq(object_path)
    end
  end

  context "when the object path has no directory separator" do
    let(:prefix) { "learning/questions" }
    let(:object_path) { "question" }

    it "returns the object path unchanged" do
      expect(merge).to eq("question")
    end
  end
end
