# Overriding to update work index after its file sets' visibilities are changed in order to have the correct file_set_visibilities.

# Responsible for copying the following attributes from the work to each file in the file_sets
#
# * visibility
# * lease
# * embargo
class VisibilityCopyJob < Hyrax::ApplicationJob
  # @api public
  # @param [#file_sets, #visibility, #lease, #embargo] work - a Work model
  def perform(work)
    if work.is_a? String
      if ActiveFedora::Base.exists?(work)
        work = ActiveFedora::Base.find(work)
      else
        Rails.logger.info "[VisibilityCopyJob] Work #{work} does not exist, skipping.."
        return
      end
    end
    work.file_sets.each do |file_set|
      file_set.visibility = work.visibility # visibility must come first, because it can clear an embargo/lease
      file_set.accessibility = work.fileset_accessibility
      copy_visibility_modifier(work: work, file_set: file_set, modifier: :lease)
      copy_visibility_modifier(work: work, file_set: file_set, modifier: :embargo)
      file_set.save!
    end
    work.update_index
  end

  private

    def copy_visibility_modifier(work:, file_set:, modifier:)
      work_modifier = work.public_send(modifier)
      return unless work_modifier
      file_set.public_send("build_#{modifier}") unless file_set.public_send(modifier)
      file_set.public_send(modifier).attributes = work_modifier.attributes.except('id')
      file_set.public_send(modifier).save
    end
end
