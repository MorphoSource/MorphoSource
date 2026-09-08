require 'rails_helper'

RSpec.describe 'records/edit_fields reviewer inputs', type: :view do
  let(:user) { FactoryBot.create(:contributor) }
  let(:reviewer) { FactoryBot.create(:contributor) }
  let(:media) { FactoryBot.create(:media, record_download_reviewer_users: [reviewer.ms_id]) }
  let(:form) { Hyrax::MediaForm.new(media, nil, nil) }

  before { allow(view).to receive(:current_user).and_return(user) }

  ['media', 'batch_submission[media]'].each do |name|
    it "renders the mode and reviewer inputs with #{name} parameter names" do
      html = view.simple_form_for(form, as: name, url: '/') do |f|
        view.render('records/edit_fields/download_reviewer_mode', f: f, submission: true) +
          view.render('records/edit_fields/record_download_reviewer_users', f: f)
      end
      document = Nokogiri::HTML.fragment(html)
      mode = document.at_css('#media_download_reviewer_mode')
      picker = document.at_css('#media_record_download_reviewer_users')

      expect(mode['name']).to eq("#{name}[download_reviewer_mode]")
      expect(picker['name']).to eq("#{name}[record_download_reviewer_users][]")
      expect(JSON.parse(picker['data-reviewers']).first['user_key']).to eq(reviewer.ms_id)
      expect(document.css('[name$="[download_reviewer][]"]')).to be_empty
      expect(mode.at_css('option[value="object_organization"]')['disabled']).to be_present
    end
  end
end
