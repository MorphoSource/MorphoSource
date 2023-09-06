# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'providers.yml' do

  let(:providers) { YAML.load_file('config/import/slides/providers.yml') }

  it { expect(providers.count).to eq(1) }

  describe 'MCZ Special Collections' do
    let(:mcz) { providers.detect { |p| p['id'] == '000357979' } }

    it 'has the correct values' do
      expect(mcz['id']).to eq('000357979')
      expect(mcz['publishing_org_key']).to eq('b4640710-8e03-11d8-b956-b8a03c50a862')
      expect(mcz['label']).to eq('MCZ Special Collections')
      expect(mcz['agreement_uri']).to eq(['https://mcz.harvard.edu/permissions-copyright'])
      expect(mcz['default_device']).to eq('TissueScope LE 120')
      expect(mcz['download_reviewer']).to eq('2956')
      expect(mcz['filter_slides']).to eq('ac:BestQuality')
      expect(mcz['fileset_accessibility']).to eq(['restricted_download'])
      expect(mcz['license']).to eq(['https://creativecommons.org/licenses/by-nc-nd/4.0/'])
      expect(mcz['list_visibility']).to eq('restricted')
      expect(mcz['manager']).to eq('f95e50')
      expect(mcz['morphosource_use_agreement_type']).to eq(['Standard'])
      expect(mcz['permits_3d_use']).to eq(['3DPrintingLimited'])
      expect(mcz['permits_commercial_use']).to eq(['CommercialUseNotPermitted'])
      expect(mcz['preview_mode']).to eq(['Interactive/Embeddable'])
      expect(mcz['publication_status']).to eq('restricted_download')
      expect(mcz['publisher']).to eq(['Museum of Comparative Zoology, Harvard University'])
      expect(mcz['required_archival_of_published_derivatives']).to eq(['OnMorphoSource'])
      expect(mcz['rights_holder']).to eq(['President and Fellows of Harvard College (Copyright and License)'])
      expect(mcz['rights_statement']).to eq(['http://rightsstatements.org/vocab/InC/1.0/'])
      expect(mcz['visibility']).to eq('open')
      expect(mcz['slide_class']).to eq('MczSlide')
      expect(mcz['normalize_permissions']).to eq(true)
    end
  end
end
