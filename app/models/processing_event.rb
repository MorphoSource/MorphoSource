class ProcessingEvent < Morphosource::Works::Base
  include ::Hyrax::WorkBehavior
  validates_with Morphosource::ParentChildValidator
  after_save :add_id_to_title, :update_media_index, :update_object_index

  self.indexer = ProcessingEventIndexer
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = [Media]

  validates :title, presence: { message: 'Your work must have a title.' }

  include Morphosource::ProcessingEventMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

  def imaging_event
    ancestors.find(&:imaging_event?)
  end

  def update_media_index
    child_media.each(&:update_index)
  end

  def child_media
    descendants.select{ |d| d.media? }
  end

  def update_object_index
    return if objects.blank?

    objects.each(&:update_index)
  end

  def objects
    ancestors.select(&:physical_object?)
  end

  private
    def add_id_to_title
      unless self.title && self.id && self.title.first.to_s.start_with?("PE#{self.id.to_s}: ")
        self.title.set("PE#{self.id.to_s}: #{self.title.first.to_s}")
      end
    end
end
