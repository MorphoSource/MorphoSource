RSpec.shared_examples '#index' do

    it 'responds with ok' do
      expect(subject).to respond_with(:ok)
    end

    it 'renders index' do
      expect(subject).to render_template(:index)
    end

end

RSpec.shared_examples '#get_items instance variables' do |page|
  let(:docs)  { { 'downloads' => [doc1,doc2,doc4],
                  'media cart' => [doc1,doc2,doc3],
                  'requests' => [doc1,doc5],
                  'request manager' => [doc5],
                  'previous requests' => [doc1]} }
  let(:items) { { 'downloads' => [cartItem1,cartItem2,cartItem4],
                  'media cart' => [cartItem1,cartItem2,cartItem3],
                  'requests' => [cartItem1,cartItem5],
                  'request manager' => [cartItem5],
                  'previous requests' => [cartItem1] } }
  let(:count) { { 'downloads' => "3 Items",
                  'media cart' => "3 Items",
                  'requests' => "2 Items",
                  'request manager' => "1 Item",
                  'previous requests' => "1 Item" } }

  it 'retrieves all the correct solr documents' do
    expect(subject.instance_variable_get(:@solr_docs)).to match_array(docs[page])
  end

  it 'retrieves all the correct items' do
    expect(subject.instance_variable_get(:@items)).to match_array(items[page])
  end

  it 'retrieves a formatted item count' do
    expect(subject.instance_variable_get(:@item_count)).to eq(count[page])
  end

end
