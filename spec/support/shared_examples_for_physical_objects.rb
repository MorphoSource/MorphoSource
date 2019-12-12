shared_examples 'a work with physical object metadata' do
   it 'has physical object descriptive metadata' do
      expect(subject.attributes.keys).to include('bibliographic_citation', 'catalog_number', 'collection_code',
                                                 'based_near', 'date_created', 'description', 'identifier',
                                                 'latitude', 'longitude', 'numeric_time', 'original_location',
                                                 'periodic_time', 'publisher', 'related_url', 'vouchered')
    end
end
