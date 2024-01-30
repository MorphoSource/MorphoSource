require 'rails_helper'

RSpec.describe Morphosource::Forms::Collections::MediaListForm do
  subject { described_class }
  let(:collection_form) { Hyrax::Forms::CollectionForm }

  it "has expected metadata terms" do
    expect(subject.terms).to match_array(collection_form.terms + [:list_type])
  end

  it "has expected required metadata terms" do
  	expect(subject.required_fields).to match_array(collection_form.required_fields)
  end

  it "has expected single valued metadata terms" do
  	expect(subject.single_valued_fields).to include(:title, :description)
  end
end
