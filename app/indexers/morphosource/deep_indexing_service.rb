module Morphosource
  class DeepIndexingService < Hyrax::DeepIndexingService
  end

  # override to cache getty labels: https://github.com/samvera/hyrax/commit/8f8a9f7744975385e788cadd73918a764283a259#diff-c030c2ef26d1ce743488da1ca6ca9e2f6276bce28e4b6f3ae97d849b4139e99e
  def fetch_with_persistence(resource)
        old_label = resource.rdf_label.first
        return unless old_label == resource.rdf_subject.to_s
        fetch_value(resource)
        return if old_label == resource.rdf_label.first || resource.rdf_label.first == resource.rdf_subject.to_s
        resource.persist! # Stores the fetched values into our marmotta triplestore
      end
end
