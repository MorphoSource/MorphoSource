require 'rails_helper'

RSpec.describe Morphosource::MultiBatchSubmissionService do
  let(:user) { create(:user) }
  let(:xlsx_path) { '/tmp/multi_batch.xlsx' }
  subject(:service) { described_class.new(xlsx_file_path: xlsx_path, user: user) }

  describe '#create_submissions' do
    let(:xlsx_file) { instance_double(Roo::Excelx) }
    let(:validator) { instance_double(BatchSubmissionTools::Ms2Batch::BatchFileValidator) }

    before do
      allow(Roo::Excelx).to receive(:new).with(xlsx_path).and_return(xlsx_file)
      allow(BatchSubmissionTools::Ms2Batch::BatchFileValidator).to receive(:new)
        .with(xlsx_file: xlsx_file, user: user)
        .and_return(validator)
      allow(service).to receive(:log_messages)
    end

    it 'creates background jobs when validation succeeds' do
      allow(validator).to receive(:validate).and_return(
        status: 'success',
        data: { warn_messages: { 1 => ['warn'] }, error_messages: {} }
      )
      allow(service).to receive(:create_background_jobs).and_return([:job])

      expect(service.create_submissions(xlsx_file_path: xlsx_path, user: user)).to eq([:job])
    end

    it 'raises when validation fails' do
      allow(validator).to receive(:validate).and_return(
        status: 'error',
        data: { error_messages: { 2 => ['bad'] } }
      )

      expect { service.create_submissions(xlsx_file_path: xlsx_path, user: user) }
        .to raise_error(/Batch file was invalid/)
    end
  end

  describe '#xlsx_to_collections' do
    let(:cell_struct) { Struct.new(:value) }
    let(:xlsx_file) { instance_double(Roo::Excelx) }

    before do
      allow(service).to receive(:xlsx_file).and_return(xlsx_file)
    end

    it 'groups rows by organization and device and returns parsed rows' do
      allow(xlsx_file).to receive(:row).with(7).and_return(
        [nil, nil, 'media.file_name', 'experimental.device_modality']
      )

      row1 = [nil, nil, cell_struct.new('a.tif'), cell_struct.new('MicroCT')]
      row2 = [nil, nil, cell_struct.new('b.tif'), cell_struct.new('MRI')]
      allow(xlsx_file).to receive(:each_row_streaming)
        .with(offset: 7, pad_cells: true)
        .and_yield(row1)
        .and_yield(row2)

      allow(xlsx_file).to receive(:cell) do |row, col|
        if row == 8 && col == 86
          1
        elsif row == 8 && col == 88
          9
        elsif row == 9 && col == 86
          2
        elsif row == 9 && col == 88
          5
        end
      end

      result = service.xlsx_to_collections

      expect(result.count).to eq(2)
      expect(result.first.keys.first).to eq(organization_id: '000000005', device_id: '000000002')
      expect(result.last.keys.first).to eq(organization_id: '000000009', device_id: '000000001')

      first_rows = result.first.values.first
      expect(first_rows.first[:media][:file_name]).to eq(['b.tif'])
      expect(first_rows.first[:experimental][:device_modality]).to eq(['MRI'])
    end
  end

  describe '#create_background_jobs' do
    it 'builds manifests and creates background jobs per org/device combo' do
      combo_1 = { { organization_id: '000000001', device_id: '000000002' } => [:row1] }
      combo_2 = { { organization_id: '000000003', device_id: '000000004' } => [:row2] }
      allow(service).to receive(:xlsx_to_collections).and_return([combo_1, combo_2])

      manifest = instance_double(BatchSubmissionTools::Ms2Batch::Manifest, to_h: { summary: {} })
      allow(service).to receive(:build_manifest).and_return(manifest)

      allow(service).to receive(:create_background_job).and_return(:job1, :job2)

      expect(service.create_background_jobs).to eq([:job1, :job2])
    end
  end

  describe '#execute_background_job' do
    let(:tempfile) { Tempfile.new(['manifest', '.xlsx']) }
    let(:background_job) do
      BackgroundJob.create!(
        data: { 'summary' => { 'manifest_tmp_file' => tempfile.path } },
        user_id: user.ms_id,
        created_objects: {}
      )
    end
    let(:renamed_file) { Rails.root.join(Dir.tmpdir, 'manifest_jid123.xlsx').to_s }

    after do
      tempfile.close
      tempfile.unlink if File.exist?(tempfile.path)
      File.delete(renamed_file) if File.exist?(renamed_file)
    end

    it 'updates job details and renames manifest temp file' do
      job_status = double('job_status', status: 'queued')
      job = double('job', job_id: 'jid123', status: job_status)
      allow(job).to receive(:class).and_return(BatchSubmissionJobs::Ms2Batch::ControlJob)

      allow(BatchSubmissionJobs::Ms2Batch::ControlJob).to receive(:perform_later)
        .with(background_job.id, background_job.user)
        .and_return(job)

      updated_job = service.execute_background_job(background_job)

      expect(updated_job.job_id).to eq('jid123')
      expect(updated_job.job_class).to eq('BatchSubmissionJobs::Ms2Batch::ControlJob')
      expect(updated_job.status).to eq('queued')

      expect(File.exist?(renamed_file)).to be(true)
    end
  end

  describe '#media_ownership_fields' do
    it 'prioritizes organization settings over options and defaults' do
      service = described_class.new(
        xlsx_file_path: xlsx_path,
        user: user,
        options: { ownership_options: { '000200001' => { 'visibility' => 'restricted', 'rights_holder' => ['John'] } } }
      )

      org = instance_double(
        OrganizationCollection,
        download_permission: 'open',
        download_reviewer: nil,
        rights_holder: nil,
        rights_statement: nil,
        license: nil,
        morphosource_use_agreement_type: nil,
        permits_commercial_use: nil,
        permits_3d_use: nil,
        required_archival_of_published_derivatives: nil,
        publisher: nil,
        preview_mode: nil,
        agreement_uri: nil,
        member_of_collection_ids: nil,
        depositor: nil
      )

      allow(OrganizationCollection).to receive(:exists?).with('000200001').and_return(org)
      allow(OrganizationCollection).to receive(:find).with('000200001').and_return(org)
      allow(service).to receive(:organization_media_transfer_for).and_return(:publication)

      fields = service.send(:media_ownership_fields, '000200001')

      expect(fields['visibility']).to eq('open')
      expect(fields['rights_holder']).to eq(['John'])
      expect(fields['organization_transfer_on_publish']).to eq(true)
      expect(fields['preview_mode']).to eq('Interactive/Embeddable')
    end
  end
end
