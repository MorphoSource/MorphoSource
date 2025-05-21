require 'rails_helper'

RSpec.describe Page, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      page = Page.new(slug: 'valid-slug', title: 'Valid Title', page_type: :pages, visibility: :published)
      expect(page).to be_valid
    end

    it 'is invalid without a slug' do
      page = Page.new(slug: nil, title: 'Valid Title', page_type: :pages, visibility: :published)
      expect(page).not_to be_valid
      expect(page.errors[:slug]).to include("can't be blank")
    end

    it 'is invalid without a title' do
      page = Page.new(slug: 'valid-slug', title: nil, page_type: :pages, visibility: :published)
      expect(page).not_to be_valid
      expect(page.errors[:title]).to include("can't be blank")
    end

    it 'is invalid with a non-unique slug' do
      Page.create!(slug: 'duplicate-slug', title: 'First Page', page_type: :pages, visibility: :published)
      page = Page.new(slug: 'duplicate-slug', title: 'Second Page', page_type: :pages, visibility: :published)
      expect(page).not_to be_valid
      expect(page.errors[:slug]).to include("has already been taken")
    end

    it 'is invalid with a slug that is not URL-friendly' do
      page = Page.new(slug: 'invalid slug!', title: 'Valid Title', page_type: :pages, visibility: :published)
      expect(page).not_to be_valid
      expect(page.errors[:slug]).to include("must be URL-friendly (only letters, numbers, and dashes are allowed)")
    end
  end

  describe 'enums' do
    it 'defines page_type enum with expected values' do
      expect(Page.page_types.keys).to contain_exactly('pages', 'docs')
    end

    it 'defines visibility enum with expected values' do
      expect(Page.visibilities.keys).to contain_exactly('unpublished', 'published')
    end
  end

  describe '#to_param' do
    it 'returns the slug as the parameter' do
      page = Page.new(slug: 'custom-slug', title: 'Valid Title', page_type: :pages, visibility: :published)
      expect(page.to_param).to eq('custom-slug')
    end
  end
end