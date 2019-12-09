RSpec.shared_context 'cart items', :shared_context => :metadata do

  let(:current_user)  { User.create(email: "example@email.com", password: "password") }

  let(:depositor)     { User.create(email: 'another@email.com', password: "password") }

  let(:work1)         { Media.create(id: "aaa", title: ["Test Media Work"], depositor: depositor.ms_id, fileset_accessibility: ['restricted_download'])}
  let(:work2)         { Media.create(id: "bbb", title: ["Test Media Work"], depositor: depositor.ms_id, fileset_accessibility: [''])}
  let(:work3)         { Media.create(id: "ccc", title: ["Test Media Work"], depositor: depositor.ms_id, fileset_accessibility: ['restricted_download'])}
  let(:work4)         { Media.create(id: "ddd", title: ["Test Media Work"], depositor: depositor.ms_id, fileset_accessibility: [''])}
  let(:work5)         { Media.create(id: "eee", title: ["Test Work Title"], depositor: depositor.ms_id, fileset_accessibility: ['restricted_download']) }
  let(:work6)         { Media.create(id: "fff", title: ["Test Work Title"], depositor: depositor.ms_id, fileset_accessibility: ['']) }
  let(:work7)         { Media.create(id: "ggg", title: ["Test Work Title"], depositor: depositor.ms_id, fileset_accessibility: ['restricted_download']) }

  let(:cartItem1)     { CartItem.create( user_id: current_user.ms_id, work_id: work1.id, in_cart: true, date_requested: Date.yesterday, date_downloaded: Date.yesterday, restricted: true, date_approved: Date.yesterday, date_expired: Date.tomorrow) }
  let(:cartItem2)     { CartItem.create( user_id: current_user.ms_id, work_id: work2.id, in_cart: true, date_downloaded: Date.yesterday, restricted: false) }
  let(:cartItem3)     { CartItem.create( user_id: current_user.ms_id, work_id: work3.id, in_cart: true, date_downloaded: nil, restricted: true) }
  let(:cartItem4)     { CartItem.create( user_id: current_user.ms_id, work_id: work4.id, in_cart: false, date_downloaded: Date.yesterday, restricted: false) }
  let(:cartItem5)     { CartItem.create( user_id: current_user.ms_id, work_id: work5.id, in_cart: false, date_downloaded: nil, restricted: true, date_requested: Date.yesterday) }
  let(:cartItem6)     { CartItem.create( user_id: current_user.ms_id, work_id: work6.id, in_cart: false, date_downloaded: nil, restricted: false) }
  let(:cartItem7)     { CartItem.create( user_id: current_user.ms_id, work_id: work7.id, in_cart: false, date_downloaded: nil, restricted: true) }

  let(:doc1)          { SolrDocument.new(id: work1.id) }
  let(:doc2)          { SolrDocument.new(id: work2.id) }
  let(:doc3)          { SolrDocument.new(id: work3.id) }
  let(:doc4)          { SolrDocument.new(id: work4.id) }
  let(:doc5)          { SolrDocument.new(id: work5.id) }
  let(:doc6)          { SolrDocument.new(id: work6.id) }
  let(:doc7)          { SolrDocument.new(id: work7.id) }


  let(:allCartItems)  { [cartItem1, cartItem2, cartItem3, cartItem4, cartItem5, cartItem6, cartItem7] }

  let(:sets)          { { 1 => {item: cartItem1, doc: doc1, work: work1},
                          2 => {item: cartItem2, doc: doc2, work: work2},
                          3 => {item: cartItem3, doc: doc3, work: work3},
                          4 => {item: cartItem4, doc: doc4, work: work4},
                          5 => {item: cartItem5, doc: doc5, work: work5},
                          6 => {item: cartItem6, doc: doc6, work: work6},
                          7 => {item: cartItem7, doc: doc7, work: work7} } }

  before do
    for x in 1..7 do
      allow(SolrDocument).to receive(:find).with(sets[x][:item].work_id).and_return(sets[x][:doc])
      allow(Media).to receive(:find).with(sets[x][:item].work_id).and_return(sets[x][:work])
    end
    sign_in current_user
  end

end
