shared_examples 'a physical object presenter' do

  describe 'method delegation' do
    it { is_expected.to delegate_method(:bibliographic_citation).to(:solr_document) }
    it { is_expected.to delegate_method(:catalog_number).to(:solr_document) }
    it { is_expected.to delegate_method(:collection_code).to(:solr_document) }
    it { is_expected.to delegate_method(:geographic_coordinates).to(:solr_document) }
    it { is_expected.to delegate_method(:institution).to(:solr_document) }
    it { is_expected.to delegate_method(:numeric_time).to(:solr_document) }
    it { is_expected.to delegate_method(:original_location).to(:solr_document) }
    it { is_expected.to delegate_method(:periodic_time).to(:solr_document) }
    it { is_expected.to delegate_method(:vouchered).to(:solr_document) }
  end

end
