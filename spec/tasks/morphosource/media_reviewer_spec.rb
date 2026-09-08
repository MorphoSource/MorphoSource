require 'rails_helper'
require 'rake'

describe 'Media reviewer migration support', type: :task do
  before { Rails.application.load_tasks if Rake::Task.tasks.empty? }

  describe Morphosource::MediaReviewerVerification do
    it 'refuses to compare legacy state after the read-path cutover' do
      expect { described_class.new.call }.to raise_error(/before.*cutover/)
    end
  end
end
