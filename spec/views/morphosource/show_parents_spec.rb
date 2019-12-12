require 'rails_helper'

RSpec.describe 'hyrax/base/_parents.html.erb', type: :view do
  let(:ability) { double }
  let(:request) { double "request", params: params }
  let(:params) { ActionController::Parameters.new(rows: 10) }

  context 'when parents are not present' do
    let(:member_list) { [] }
    let(:presenter) { double(:presenter, work: work, member_presenters_for: member_list, id: 'the-id', human_readable_type: 'Thing') }
    let(:work) { double(:work, in_works_ids: member_list)}

    before do
      expect(work).to receive(:in_works_ids).and_return(member_list)
    end

    context 'and the current user can edit the presenter' do
      it 'renders an alert' do
        expect(view).to receive(:can?).with(:edit, presenter.id).and_return(true)
        render 'hyrax/base/parents', presenter: presenter
        expect(rendered).to have_css('.alert-warning[role=alert]', text: 'This Thing has no files associated with it. Click "edit" to add more files.')
      end
    end
    context 'and the current user cannot edit the presenter' do
      it 'renders an alert' do
        expect(view).to receive(:can?).with(:edit, presenter.id).and_return(false)
        render 'hyrax/base/parents', presenter: presenter
        expect(rendered).to have_css('.alert-warning[role=alert]', text: "There are no publicly available items in this Thing.")
      end
    end
  end
  #
  context 'when parents are present' do
    let(:parent1) { double('Parent1', id: 'Parent 1', title: 'Parent 1') }
    let(:parent2) { double('Parent2', id: 'Parent 2', title: 'Parent 2') }
    let(:parent3) { double('Parent3', id: 'Parent 3', title: 'Parent 3') }
    let(:member_list) { [parent1, parent2, parent3] }
    let(:member_list_ids) { ['Parent 1', 'Parent 2', 'Parent 3']}
    let(:presenter) { double(:presenter, work: work, member_presenters_for: member_list, id: 'the-id', human_readable_type: 'Thing') }
    let(:work) { double(:work, in_works_ids: member_list_ids)}


    let(:page) do
        render 'hyrax/base/parents', presenter: presenter
        Capybara::Node::Simple.new(rendered)
      end

    before do
      stub_template 'hyrax/base/_member.html.erb' => '<%= member %>'
      allow(presenter).to receive(:total_pages).and_return(1)
      allow(presenter).to receive(:list_of_item_ids_to_display).and_return(member_list_ids)
    end

    it "shows the parents heading" do
      expect(page).to have_content("Parents")
    end

    it "shows parents" do
      expect(page).to have_css('tbody')
      expect(page).to have_content(/Parent1/)
      expect(page).to have_content(/Parent2/)
      expect(page).to have_content(/Parent3/)
    end

  end
end
