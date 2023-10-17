class OrganizationCollection < Collection

  def initialize(params=nil)
    super
    self.collection_type_gid = collection_type.gid
  end

  def self.collection_type
    Hyrax::CollectionType.find_by(Morphosource::CollectionTypes::Organizations::SETTINGS)
  end

  def collection_type
    self.class.collection_type
  end

  def human_readable_type
    'Organization'
  end
end