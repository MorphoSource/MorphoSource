require 'rails_helper'

RSpec.describe Hyrax::Actors::CreateWithFilesActor do
  let(:user)            { create(:user) }
  let(:ability)         { ::Ability.new(user) }
  let(:work)            { create(:media, depositor: user.user_key) }
  let(:terminator)      { Hyrax::Actors::Terminator.new }
  let(:uploaded_file1)  { create(:uploaded_file, user: user) }
  let(:uploaded_file2)  { create(:uploaded_file, user: user) }
  let(:uploaded_file_ids) { [uploaded_file1.id, uploaded_file2.id] }
  let(:attributes)      { { uploaded_files: uploaded_file_ids } }
  let(:env)             { Hyrax::Actors::Environment.new(work, ability, attributes) }

  subject(:middleware) do
    stack = ActionDispatch::MiddlewareStack.new.tap { |ms| ms.use described_class }
    stack.build(terminator)
  end

  [:create, :update].each do |mode|
    context "on #{mode}" do
      before { allow(terminator).to receive(mode).and_return(true) }

      context "when uploaded_file_ids contain nil entries" do
        let(:uploaded_file_ids) { [nil, uploaded_file1.id, nil] }

        it "discards nil values before looking up files" do
          expect(AttachFilesToWorkJob).to receive(:perform_later)
          expect(Hyrax::UploadedFile).to receive(:find)
            .with([uploaded_file1.id]).and_return([uploaded_file1])
          middleware.public_send(mode, env)
        end
      end

      context "when all uploaded files belong to the depositor" do
        it "enqueues AttachFilesToWorkJob with the work and files" do
          expect(AttachFilesToWorkJob).to receive(:perform_later)
            .with(work, [uploaded_file1, uploaded_file2], any_args)
          expect(middleware.public_send(mode, env)).to be true
        end
      end

      context "when an uploaded file belongs to a different user" do
        let(:other_file) { create(:uploaded_file) } # different user
        let(:uploaded_file_ids) { [uploaded_file1.id, other_file.id] }

        it "does not enqueue the job and returns false" do
          expect(AttachFilesToWorkJob).not_to receive(:perform_later)
          expect(middleware.public_send(mode, env)).to be false
        end
      end

      context "when no uploaded_files attribute is present" do
        let(:attributes) { {} }

        it "does not enqueue the job and returns true" do
          expect(AttachFilesToWorkJob).not_to receive(:perform_later)
          expect(middleware.public_send(mode, env)).to be true
        end
      end

      # MorphoSource-specific: remote-backed media has no UploadedFile; its
      # file set is created by AttachRemoteFilesToWorkJob, not this actor.
      context "when the work is remote-backed media" do
        before do
          allow(work).to receive(:media?).and_return(true)
          allow(work).to receive(:is_remote_backed?).and_return(true)
        end

        it "skips the job and returns true" do
          expect(AttachFilesToWorkJob).not_to receive(:perform_later)
          expect(middleware.public_send(mode, env)).to be true
        end
      end

      # MorphoSource-specific: prevent duplicate file sets on media resubmission.
      context "when the work is media that already has file sets" do
        before do
          allow(work).to receive(:media?).and_return(true)
          allow(work).to receive(:is_remote_backed?).and_return(false)
          allow(work).to receive_message_chain(:file_sets, :count).and_return(1)
        end

        it "skips the job to avoid duplicate file sets" do
          expect(AttachFilesToWorkJob).not_to receive(:perform_later)
          expect(middleware.public_send(mode, env)).to be true
        end
      end

      context "when the work is non-media (e.g. PhysicalObject) with files" do
        before do
          allow(work).to receive(:media?).and_return(false)
        end

        it "enqueues the job regardless of file_sets state" do
          expect(AttachFilesToWorkJob).to receive(:perform_later)
          middleware.public_send(mode, env)
        end
      end
    end
  end
end
