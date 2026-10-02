require 'rails_helper'

RSpec.describe Hyrax::Actors::CreateWithRemoteFilesActor do
  let(:user)        { create(:user) }
  let(:ability)     { ::Ability.new(user) }
  let(:work)        { create(:media, depositor: user.user_key) }
  let(:terminator)  { Hyrax::Actors::Terminator.new }
  let(:remote_files) { [{ url: 'https://example.com/model.ply', file_name: 'model.ply' }] }
  let(:attributes)  { { remote_files: remote_files } }
  let(:env)         { Hyrax::Actors::Environment.new(work, ability, attributes) }

  subject(:middleware) do
    stack = ActionDispatch::MiddlewareStack.new.tap { |ms| ms.use described_class }
    stack.build(terminator)
  end

  [:create, :update].each do |mode|
    context "on #{mode}" do
      before { allow(terminator).to receive(mode).and_return(true) }

      context "when remote_files are present" do
        it "enqueues AttachRemoteFilesToWorkJob and returns true" do
          expect(AttachRemoteFilesToWorkJob).to receive(:perform_later)
            .with(work, remote_files)
          expect(middleware.public_send(mode, env)).to be true
        end
      end

      context "when remote_files is blank" do
        let(:attributes) { {} }

        it "does not enqueue the job and returns true" do
          expect(AttachRemoteFilesToWorkJob).not_to receive(:perform_later)
          expect(middleware.public_send(mode, env)).to be true
        end
      end

      # MorphoSource-specific: remote-backed Media derives its remote_files from
      # remote_origin_url rather than an explicit :remote_files attribute.
      context "when the work is remote-backed media with a remote_origin_url" do
        let(:remote_url) { 'https://remote.example.com/specimens/mesh.ply' }
        let(:attributes) { { 'remote_origin_url' => remote_url } }

        before { allow(work).to receive(:media?).and_return(true) }

        it "builds remote_files from the URL and enqueues the job" do
          expect(AttachRemoteFilesToWorkJob).to receive(:perform_later)
            .with(work, [{ url: remote_url, file_name: 'mesh.ply' }])
          middleware.public_send(mode, env)
        end
      end

      # When a remote manifest supplies a different file_name and mime_type,
      # those values override the basename derived from the URL.
      context "when the work is remote-backed media with remote_manifest_info" do
        let(:remote_url) { 'https://remote.example.com/specimens/mesh' }
        let(:attributes) do
          {
            'remote_origin_url' => remote_url,
            remote_manifest_info: { 'file_name' => 'scan.ply', 'mime_type_of_remote' => 'model/ply' }
          }
        end

        before { allow(work).to receive(:media?).and_return(true) }

        it "merges manifest file_name and mime_type into the remote_files hash" do
          expect(AttachRemoteFilesToWorkJob).to receive(:perform_later)
            .with(work, [{ url: remote_url, file_name: 'scan.ply', mime_type_of_remote: 'model/ply' }])
          middleware.public_send(mode, env)
        end
      end

      # Guard: a Media work that already has a FileSet must not get a second one
      # on re-save/update. Without this guard, editing and re-saving a remote-backed
      # media would enqueue AttachRemoteFilesToWorkJob again.
      context "when the work is media with an existing file set" do
        before do
          allow(work).to receive(:media?).and_return(true)
          allow(work).to receive(:file_sets).and_return(double(count: 1))
        end

        it "does not enqueue the job and returns true" do
          expect(AttachRemoteFilesToWorkJob).not_to receive(:perform_later)
          expect(middleware.public_send(mode, env)).to be true
        end
      end

      context "when the work is media with no existing file sets" do
        before do
          allow(work).to receive(:media?).and_return(true)
          allow(work).to receive(:file_sets).and_return(double(count: 0))
        end

        it "enqueues the job" do
          expect(AttachRemoteFilesToWorkJob).to receive(:perform_later)
            .with(work, remote_files)
          middleware.public_send(mode, env)
        end
      end

      context "when the work is not a media (e.g. ProcessingEvent)" do
        before do
          allow(work).to receive(:media?).and_return(false)
          allow(work).to receive(:file_sets).and_return(double(count: 1))
        end

        it "enqueues the job regardless of existing file sets" do
          expect(AttachRemoteFilesToWorkJob).to receive(:perform_later)
            .with(work, remote_files)
          middleware.public_send(mode, env)
        end
      end
    end
  end
end
