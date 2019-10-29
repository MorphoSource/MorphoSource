require 'rails_helper'

RSpec.feature 'Display a Media Work' do
  let(:title)             {['Media Work Title']}
  let(:date_modified)     {'09/13/2018'}
  let(:publisher)         {['Random House']}
  let(:identifier)        {['123ABC']}
  let(:keyword)           {['purple']}
  let(:date_created)      {['January 1, 1977']}
  let(:related_url)       {['www.aaa.com']}
  let(:rights_statement)  {['In Copyright - EU Orphan Work']}
  let(:agreement_uri)     {['www.zzz.com']}
  let(:cite_as)           {['Media Work Citation']}
  let(:funding)           {['NSF']}
  let(:map_type)          {['Color Map']}
  let(:media_type)        {['PhotogrammetryImageStack']}
  let(:orientation)       {['Media Orientation']}
  let(:part)              {['Part 7']}
  let(:rights_holder)     {['Martha Stewart']}
  let(:scale_bar)         {['Type: Scale_bar_target_type, Distance: Scale_bar_distance, Units: Scale_bar_units']}
  let(:side)              {['left']}
  let(:unit)              {['inch']}
  let(:x_spacing)         {['5']}
  let(:y_spacing)         {['7']}
  let(:z_spacing)         {['9']}
  let(:visibility)        { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
  let(:user)              { 'test@example.com' }

  let :work do
    Media.create(title:            title,
                 date_modified:    date_modified,
                 publisher:        publisher,
                 identifier:       identifier,
                 keyword:          keyword,
                 date_created:     date_created,
                 related_url:      related_url,
                 rights_statement: rights_statement,
                 agreement_uri:    agreement_uri,
                 cite_as:          cite_as,
                 funding:          funding,
                 map_type:         map_type,
                 media_type:       media_type,
                 orientation:      orientation,
                 part:             part,
                 rights_holder:    rights_holder,
                 scale_bar:        scale_bar,
                 side:             side,
                 unit:             unit,
                 x_spacing:        x_spacing,
                 y_spacing:        y_spacing,
                 z_spacing:        z_spacing,
                 visibility:       visibility,
                 depositor:        user)
  end

  scenario "Show a public Work" do
    visit("/concern/media/show/#{work.id}") # default show page has been moved to a different path: .../show/...

    expect(page).to have_content work.date_modified.first
    expect(page).to have_content work.publisher.first
    expect(page).to have_content work.identifier.first
    expect(page).to have_content work.keyword.first
    expect(page).to have_content work.date_created.first
    expect(page).to have_content work.related_url.first
    expect(page).to have_content work.rights_statement.first
    expect(page).to have_content work.agreement_uri.first
    expect(page).to have_content work.cite_as.first
    expect(page).to have_content work.funding.first
    expect(page).to have_content work.map_type.first
    expect(page).to have_content work.media_type.first
    expect(page).to have_content work.orientation.first
    expect(page).to have_content work.part.first
    expect(page).to have_content work.rights_holder.first
    expect(page).to have_content work.scale_bar.first
    expect(page).to have_content work.side.first
    expect(page).to have_content work.unit.first
    expect(page).to have_content work.x_spacing.first
    expect(page).to have_content work.y_spacing.first
    expect(page).to have_content work.z_spacing.first

  end
end
