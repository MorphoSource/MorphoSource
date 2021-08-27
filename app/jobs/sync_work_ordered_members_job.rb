class SyncWorkOrderedMembersJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_slow_queue_name

  def perform(object=nil)
  	if object.present? && ( (m_len = object.members.to_a.length) != (om_len = object.ordered_members.to_a.length) )
  		if om_len > m_len
  			object.members = object.ordered_members
  		elsif m_len > om_len
  			object.ordered_members = object.members
  		end
  		object.save!
  	end
  end
end