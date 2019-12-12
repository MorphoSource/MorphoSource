require 'rails_helper'

RSpec.describe Morphosource::FormMethods do

  let(:work) { Media.new }
  let(:controller) { instance_double(Hyrax::MediaController) }
  let(:form) { Hyrax::MediaForm.new(work, nil, controller) }
  let(:parent_work) { Media.create(title: ["Example Parent Work"], id: "ParentWork") }
  let(:parent_id) { parent_work.id }
  let(:parent_path) { "parent path" }

  before do
    allow(controller).to receive(:params).and_return(parent_id: parent_id)
    allow(controller).to receive(:url_for).and_return(parent_path)
  end

  describe "#member_of_works_json" do
    subject { form.member_of_works_json }

    it { is_expected.to include("ParentWork") }
    it { is_expected.to include("Example Parent Work") }

  end
end
