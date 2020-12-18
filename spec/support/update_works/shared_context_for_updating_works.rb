RSpec.shared_context 'update works', :shared_context => :metadata do
  RSpec::Matchers.define_negated_matcher :not_change, :change

  let(:user)                      { User.create(email: 'email@email.com', password: 'password') }
  let(:contributors)              { Role.create(name: 'contributor') }

  let(:organization)              { Organization.create(title: ['old title']) }
  let(:taxonomy)                  { Taxonomy.create(title: ['old title']) }
  let(:specimen)                  { BiologicalSpecimen.create(title: ['old title'], vouchered: ['Yes']) }
  let(:device)                    { Device.create(title: ['device'], modality: ["MagneticResonanceImaging"])}
  let(:imaging_event)             { ImagingEvent.create(title: ['old title'], ie_modality: device.modality, device_id: [device.id]) }
  let(:media1)                    { Media.create(title: ['old title']) }
  let(:processing_event)          { ProcessingEvent.create(title: ['old title']) }
  let(:media2)                    { Media.create(title: ['old title']) }
  let(:specimen_works)            { [organization, taxonomy, specimen, imaging_event, media1, processing_event, media2] }

  let(:old_organization_doc)      { SolrDocument.find(organization.id) }
  let(:old_taxonomy_doc)          { SolrDocument.find(taxonomy.id) }
  let(:old_specimen_doc)          { SolrDocument.find(specimen.id) }
  let(:old_imaging_event_doc)     { SolrDocument.find(imaging_event.id) }
  let(:old_media1_doc)            { SolrDocument.find(media1.id) }
  let(:old_processing_event_doc)  { SolrDocument.find(processing_event.id) }
  let(:old_media2_doc)            { SolrDocument.find(media2.id) }

  let(:old_docs)                  { [old_organization_doc, old_taxonomy_doc, old_specimen_doc, old_imaging_event_doc, old_media1_doc, old_processing_event_doc, old_media2_doc] }

  let(:new_organization_doc)      { SolrDocument.find(organization.id) }
  let(:new_taxonomy_doc)          { SolrDocument.find(taxonomy.id) }
  let(:new_specimen_doc)          { SolrDocument.find(specimen.id) }
  let(:new_imaging_event_doc)     { SolrDocument.find(imaging_event.id) }
  let(:new_media1_doc)            { SolrDocument.find(media1.id) }
  let(:new_processing_event_doc)  { SolrDocument.find(processing_event.id) }
  let(:new_media2_doc)            { SolrDocument.find(media2.id) }

  before do
    taxonomy.members << specimen
    organization.members << specimen
    specimen.members << imaging_event
    imaging_event.members << media1
    media1.members << processing_event
    processing_event.members << media2
    specimen_works.each(&:save)
  end
end
