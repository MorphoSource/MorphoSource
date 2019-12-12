# Generated via
#  `rails generate hyrax:work ProcessingEvent`
require 'rails_helper'

RSpec.describe Hyrax::ProcessingEventForm do
  let(:all_metadata_fields) { [:creator, :date_created, :description, :software, :processing_activity, :processing_activity_description, :processing_activity_software, :processing_activity_type] }
  let(:required_fields) { [] }
  let(:single_value_fields) { [:description, :date_created] }

  describe 'class attributes' do

    it 'has expected metadata terms' do
      expect(described_class.terms).to include(:creator, :date_created, :description, :software)
    end

    it "has expected required metadata terms" do
      expect(described_class.required_fields).to match_array(required_fields)
    end

    it "has expected single valued metadata terms" do
      expect(described_class.single_valued_fields).to match_array(single_value_fields)
    end

  end

  describe 'instance methods' do

    let(:work) { ProcessingEvent.new }
    let(:ability) { double }
    let(:controller) { double }

    subject { described_class.new(work, ability, controller) }

    it 'has the expected primary metadata terms' do
      expect(subject.primary_terms).to match_array(all_metadata_fields)
    end

  end

end
