require 'rails_helper'

RSpec.describe Hyrax::PermissionTemplateApplicator do
  subject(:applicator)          { described_class.new(template: template) }
  let(:manage_groups)           { ['managers_group'] }
  let(:manage_users)            { ['manage_user'] }
  let(:work_editor_groups)      { ['editors_group'] }
  let(:work_downloader_groups)  { ['downloaders_group'] }
  let(:view_groups)             { ['viewers_group'] }
  let(:view_users)              { ['view_user'] }
  let(:work)                    { Media.create(title: ['media']) }

  describe '.apply' do
    let(:template)       { :not_a_template }

    it 'initializes with template' do
      expect(described_class.apply(template))
        .to have_attributes(template: template)
    end
  end

  describe '#apply_to' do
    let(:template) { Hyrax::PermissionTemplate.create() }

    before do
      # groups
      Hyrax::PermissionTemplateAccess.create(permission_template: template, agent_type: 'group', agent_id: 'managers_group', access: Hyrax::PermissionTemplateAccess::MANAGE)
      Hyrax::PermissionTemplateAccess.create(permission_template: template, agent_type: 'group', agent_id: 'editors_group', access: Hyrax::PermissionTemplateAccess::EDIT_WORKS)
      Hyrax::PermissionTemplateAccess.create(permission_template: template, agent_type: 'group', agent_id: 'downloaders_group', access: Hyrax::PermissionTemplateAccess::DOWNLOAD_WORKS)
      Hyrax::PermissionTemplateAccess.create(permission_template: template, agent_type: 'group', agent_id: 'viewers_group', access: Hyrax::PermissionTemplateAccess::VIEW)

      # users
      Hyrax::PermissionTemplateAccess.create(permission_template: template, agent_type: 'user', agent_id: 'manage_user', access: Hyrax::PermissionTemplateAccess::MANAGE)
      Hyrax::PermissionTemplateAccess.create(permission_template: template, agent_type: 'user', agent_id: 'view_user', access: Hyrax::PermissionTemplateAccess::VIEW)

    end

    # adds both manage and edit_works access groups as work editors
    it 'applies edit groups' do
      edit_after_application = work.edit_groups + manage_groups + work_editor_groups

      expect { applicator.apply_to(model: work) }
        .to change { work.edit_groups }
        .to contain_exactly(*edit_after_application)
    end

    it 'applies edit users' do
      edit_after_application = work.edit_users + manage_users

      expect { applicator.apply_to(model: work) }
        .to change { work.edit_users }
        .to contain_exactly(*edit_after_application)
    end

    it 'applies download groups' do
      download_after_application = work_downloader_groups

      expect { applicator.apply_to(model: work) }
       .to change { work.download_groups }
       .to contain_exactly(*download_after_application)
    end

    it 'applies read groups' do
      read_after_application = work.read_groups + view_groups

      expect { applicator.apply_to(model: work) }
        .to change { work.read_groups }
        .to contain_exactly(*read_after_application)
    end

    it 'applies read users' do
      read_after_application = work.read_users + view_users

      expect { applicator.apply_to(model: work) }
        .to change { work.read_users }
        .to contain_exactly(*read_after_application)
    end

    context 'work already has same access grants' do
      before do
        work.edit_groups += ['managers_group', 'editors_group']
        work.edit_users += ['manage_user']
        work.download_groups += ['downloaders_group']
        work.read_groups += ['viewers_group']
        work.read_users += ['view_user']
        work.save
      end
      it 'does not add duplicate edit groups' do
        expect { applicator.apply_to(model: work) }
         .not_to change { work.edit_groups }
      end
      it 'does not add duplicate edit users' do
        expect { applicator.apply_to(model: work) }
         .not_to change { work.edit_users }
      end
      it 'does not add duplicate download groups' do
        expect { applicator.apply_to(model: work) }
         .not_to change { work.download_groups }
      end
      it 'does not add duplicate read groups' do
        expect { applicator.apply_to(model: work) }
         .not_to change { work.read_groups }
      end
      it 'does not add duplicate read users' do
        expect { applicator.apply_to(model: work) }
         .not_to change { work.read_users }
      end
    end
  end

  describe '#template' do
    let(:template)     { :not_a_template }
    let(:new_template) { :not_another_template }

    it 'has a template attribute' do
      expect { applicator.template = new_template }
        .to change { applicator.template }
        .from(template)
        .to new_template
    end
  end
end
