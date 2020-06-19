# frozen_string_literal: true

# Generated via
# `rails generate hyrax:work Organization`
require 'rails_helper'

RSpec.describe Morphosource::AccessControls::Permissions do

  let(:media) { Media.create(title: ['new media']) }
  let(:downloader_group)  { Role.create(name: 'downloader_group') }
  let(:downloader_group2) { Role.create(name: 'downloader_group2') }
  let(:download_user)     { User.create(email: 'downloader@email.com', password: 'password') }
  let(:download_user2)    { User.create(email: 'downloader2@email.com', password: 'password') }


  describe '#download_groups' do
    subject { media.download_groups }
    before do
      media.download_groups = [downloader_group, downloader_group2]
    end
    it { expect(subject).to match_array([downloader_group.name, downloader_group2.name]) }
  end
  describe '#download_groups=' do
    subject { media.permissions }
    context 'array of groups' do
      before do
        media.download_groups= [downloader_group, downloader_group2]
      end
      it 'assigns the groups' do
        expect(subject[0].to_hash).to eq({:name=>"downloader_group", :type=>"group", :access=>"download"})
        expect(subject[1].to_hash).to eq({:name=>"downloader_group2", :type=>"group", :access=>"download"})
      end
    end
    context 'array of group names' do
      before do
        media.download_groups= [downloader_group.name, downloader_group2.name]
      end
      it 'assigns the groups' do
        expect(subject[0].to_hash).to eq({:name=>"downloader_group", :type=>"group", :access=>"download"})
        expect(subject[1].to_hash).to eq({:name=>"downloader_group2", :type=>"group", :access=>"download"})
      end
    end
    context 'media already has a download group' do
      before do
        media.download_groups= [downloader_group]
        media.download_groups= [downloader_group2]
      end
      it 'replaces it with the passed groups' do
        expect(subject[0].to_hash).to eq({:name=>"downloader_group2", :type=>"group", :access=>"download"})
      end
    end
    context 'adding a download group' do
      let(:downloader_group3) { Role.create(name: 'downloader_group3') }
      before do
        media.download_groups = [downloader_group, downloader_group2]
        media.save
      end
      context 'adding an array of groups' do
        before do
          media.download_groups += [downloader_group3]
          media.save
        end
        it 'adds the group' do
          expect(subject[0].to_hash).to eq({:name=>"downloader_group", :type=>"group", :access=>"download"})
          expect(subject[1].to_hash).to eq({:name=>"downloader_group2", :type=>"group", :access=>"download"})
          expect(subject[2].to_hash).to eq({:name=>"downloader_group3", :type=>"group", :access=>"download"})
        end
      end
      context 'adding an array of group names' do
        before do
          media.download_groups += ['downloader_group3']
          media.save
        end
        it 'adds the group' do
          expect(subject[0].to_hash).to eq({:name=>"downloader_group", :type=>"group", :access=>"download"})
          expect(subject[1].to_hash).to eq({:name=>"downloader_group2", :type=>"group", :access=>"download"})
          expect(subject[2].to_hash).to eq({:name=>"downloader_group3", :type=>"group", :access=>"download"})
        end
      end
    end
  end
  describe '#download_groups_string=' do
    subject{ media.download_groups }
    before do
      media.download_groups_string= "#{downloader_group.name},#{downloader_group2.name}"
    end
    it {expect(subject).to match_array([downloader_group.name, downloader_group2.name])}
  end
  describe '#download_groups_string' do
    subject { media.download_groups_string }
    before do
      media.download_groups= [downloader_group, downloader_group2]
    end
    it { expect(subject).to eq("#{downloader_group.name}, #{downloader_group2.name}")}
  end
  describe '#set_download_groups' do
    subject { media.download_groups }
    before do
      media.download_groups = [downloader_group, downloader_group2]
      media.set_download_groups([downloader_group], [downloader_group2])
    end
    it { expect(subject).to eq([downloader_group.name]) }
  end
  describe '#download_users' do
    subject { media.download_users }
    before do
      media.download_users = [download_user, download_user2]
    end
    it { expect(subject).to match_array([download_user.ms_id, download_user2.ms_id]) }
  end
  describe '#download_users=' do
    subject { media.permissions }
    before do
      media.download_users = [download_user, download_user2]
    end
    it 'assigns the users download permission' do
      expect(subject[0].to_hash).to eq({:name=>download_user.ms_id, :type=>"person", :access=>"download"})
      expect(subject[1].to_hash).to eq({:name=>download_user2.ms_id, :type=>"person", :access=>"download"})
    end
    context 'adding additional users' do
      let(:download_user3) { User.create(email: 'downloader3@email.com', password: 'password') }
      context 'adding an array of users' do
        before do
          media.download_users += [download_user3]
          media.save
        end
        it 'assigns the users download permission' do
          expect(subject[0].to_hash).to eq({:name=>download_user.ms_id, :type=>"person", :access=>"download"})
          expect(subject[1].to_hash).to eq({:name=>download_user2.ms_id, :type=>"person", :access=>"download"})
          expect(subject[2].to_hash).to eq({:name=>download_user3.ms_id, :type=>"person", :access=>"download"})
        end
      end
      context 'adding an array of user ids' do
        before do
          media.download_users += [download_user3.ms_id]
          media.save
        end
        it 'assigns the users download permission' do
          expect(subject[0].to_hash).to eq({:name=>download_user.ms_id, :type=>"person", :access=>"download"})
          expect(subject[1].to_hash).to eq({:name=>download_user2.ms_id, :type=>"person", :access=>"download"})
          expect(subject[2].to_hash).to eq({:name=>download_user3.ms_id, :type=>"person", :access=>"download"})
        end
      end
    end
  end
  describe '#download_users_string=' do
    subject{ media.download_users }
    before do
      media.download_users_string= "#{download_user.ms_id},#{download_user2.ms_id}"
    end
    it {expect(subject).to match_array([download_user.ms_id, download_user2.ms_id])}
  end
  describe '#download_users_string' do
    subject { media.download_users_string }
    before do
      media.download_users = [download_user, download_user2]
    end
    it { expect(subject).to eq("#{download_user.ms_id}, #{download_user2.ms_id}")}
  end
  describe '#set_download_users' do
    subject { media.download_users }
    before do
      media.download_users = [download_user, download_user2]
      media.set_download_users([download_user], [download_user2])
    end
    it { expect(subject).to eq([download_user.ms_id]) }
  end
end
