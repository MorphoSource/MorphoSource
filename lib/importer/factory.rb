module Importer
  module Factory
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :CollectionFactory
      autoload :DatasetFactory
      autoload :ObjectFactory
      autoload :WithAssociatedCollection
    end

    # @param [#to_s] First (Xxx) portion of an "XxxFactory" constant
    def self.for(model_name)
      const_get "#{model_name}Factory"
    end
  end
end
