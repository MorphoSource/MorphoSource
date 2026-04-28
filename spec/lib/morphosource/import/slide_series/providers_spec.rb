# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Import::SlideSeries::Providers do

  let(:klass)     { Class.new { include Morphosource::Import::SlideSeries::Providers } }
  let(:subject)   { klass.new }
  let(:providers) { YAML.load_file('config/import/slides/providers.yml') }

  describe 'class methods' do
    describe '.providers' do
      it { expect(klass.providers).to eq(providers) }
    end
    describe '.provider_methods' do
      let(:provider_methods) do
        %w[agreement_uri
           default_device
           fileset_accessibility
           filter_slides
           license
           list_visibility
           morphosource_use_agreement_type
           normalize_permissions
           permits_3d_use
           permits_commercial_use
           preview_mode
           publication_status
           publisher
           required_archival_of_published_derivatives
           rights_holder
           rights_statement
           visibility]
      end

      it { expect(klass.provider_methods).to match_array(provider_methods) }
    end

    describe '.define_provider_methods' do
      it 'defines all of the provider_methods' do
        klass.provider_methods.each do |method|
          expect(klass).to receive(:define_method).with(method)
        end
        klass.define_provider_methods
      end
    end
  end

  describe 'instance methods' do
    let(:publishing_key)  { 'b4640710-8e03-11d8-b956-b8a03c50a862' }
    let(:provider)        { providers.detect { |p| p['id'] == '000839463' } }
    before do
      allow(subject).to receive(:publishing_key).and_return(publishing_key)
    end

    describe 'download_reviewer' do
      let!(:download_reviewer) { FactoryBot.create(:user, ms_id: provider['download_reviewer']) }

      it { expect(subject.download_reviewer).to eq(download_reviewer) }
    end

    describe 'manager' do
      let!(:manager) { FactoryBot.create(:user, ms_id: provider['manager']) }

      it { expect(subject.manager).to eq(manager) }
    end

    describe 'provider' do
      it { expect(subject.provider).to eq(provider) }
    end

    describe 'detect_provider' do
      it { expect(subject.detect_provider(publishing_key)).to eq(provider) }
    end
  end
end
