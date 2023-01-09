# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::My::CollectionsController do

  # helpers/morphosource/my/works_helper
  describe '#search_action_for_dashboard' do
    let(:hyrax)   { Hyrax::Engine.routes.url_helpers }
    let(:params)  { { controller: controller.controller_path } }
    subject       { controller.view_context }

    before do
      allow(subject).to receive(:params).and_return(params)
    end

    it { expect(subject.search_action_for_dashboard).to eq(hyrax.my_collections_path(locale: 'en')) }
  end
end
