# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::Dashboard::NestCollectionsController, type: :controller do
  routes { Hyrax::Engine.routes }

  let(:child_id) { 'child1' }
  let(:child) { instance_double(Collection, title: ['Awesome Child']) }
  let(:team_collection_type) { Hyrax::CollectionType.create(title: 'Team', machine_id: 'team') }
  let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project', machine_id: 'project') }
  let(:parent) { Collection.create(id: 'parent1', title: ['Uncool Parent'], collection_type_gid: team_collection_type.gid) }

  describe '#selected_type_id' do
    let(:form_class_with_successful_validation) do
        Class.new do
          attr_reader :child, :parent
          def initialize(parent:, child:, context:)
            @parent = parent
            @child = child
            @context = context
          end

          def validate_add
            true
          end
        end
      end

    before do
      allow(Collection).to receive(:find).with(parent.id).and_return(parent)
      controller.form_class = form_class_with_successful_validation
      allow(controller).to receive(:authorize!).with(:deposit, parent).and_return(true)
      allow(Hyrax::CollectionType).to receive(:find_by).with(machine_id: 'project').and_return(project_collection_type)
    end

    context 'nesting a project under a team' do
      subject { get 'create_collection_under', params: { child_id: nil, parent_id: parent.id, source: 'show', collection_type: 'project' } }

      it 'redirects to a new project' do
        subject
        expect(response).to redirect_to new_dashboard_collection_path(collection_type_id: project_collection_type.id, parent_id: parent.id)
      end
    end

    context 'nesting another nestable collection' do
      subject { get 'create_collection_under', params: { child_id: nil, parent_id: parent.id, source: 'show' } }

      it 'redirects to a new collection with the same type as the parent' do
        subject
        expect(response).to redirect_to new_dashboard_collection_path(collection_type_id: parent.collection_type.id, parent_id: parent.id)
      end
    end
  end
end
