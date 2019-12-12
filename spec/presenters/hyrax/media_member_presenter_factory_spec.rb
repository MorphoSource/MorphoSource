require 'rails_helper'

RSpec.describe Hyrax::MediaMemberPresenterFactory do
	describe 'media member presenter factory' do
		it 'has MediaFileSetPresenter as the file_presenter_class' do
			expect(described_class.file_presenter_class).to eq(Hyrax::MediaFileSetPresenter)
		end
	end
end