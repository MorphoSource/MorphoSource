# Register MorphoSource-specific transactions and steps here

class ApplicationContainerOverrides
  extend Dry::Container::Mixin

  namespace 'taxonomy_change_set' do |ops|
    ops.register 'create_work' do
      Morphosource::Transactions::Taxonomy::WorkCreate.new
    end

    ops.register 'set_source' do
      Morphosource::Transactions::Taxonomy::Steps::SetSource.new
    end

    ops.register 'set_title' do
      Morphosource::Transactions::Taxonomy::Steps::SetTitle.new
    end

    ops.register 'set_trusted' do
      Morphosource::Transactions::Taxonomy::Steps::SetTrusted.new
    end

    ops.register 'update_work' do
      Morphosource::Transactions::Taxonomy::WorkUpdate.new
    end
  end
end

Hyrax::Transactions::Container.merge(ApplicationContainerOverrides)

# If not creating a new namespace, instead just register the new transaction here, i.e.
# Hyrax::Transactions::Container.register('work_resource.mint_id', MintId.new)