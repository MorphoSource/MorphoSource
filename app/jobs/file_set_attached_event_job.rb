# frozen_string_literal: true
# Copied from Hyrax 5.0.5, modified for MorphoSource hybrid AF/Valkyrie relationships
# Log a fileset attachment to activity streams
class FileSetAttachedEventJob < ContentEventJob
  # Log the event to the fileset's and its container's streams
  def log_event(repo_object)
    repo_object.log_event(event)
    curation_concern&.log_event(event)
  end

  def action
    "User #{link_to_profile depositor} has attached #{file_link} to #{work_link}"
  end

  private

  def file_link
    link_to file_title, polymorphic_path(repo_object)
  end

  def work_link
    return '' unless curation_concern
    link_to work_title, polymorphic_path(curation_concern)
  end

  def file_title
    repo_object.title.first
  end

  def work_title
    curation_concern&.title&.first
  end

  def curation_concern
    case repo_object
    when ActiveFedora::Base
      repo_object.in_works.first
    else # todovalk: change this back to Hyrax default when Media is valkyrized
      # Hyrax default:
      # Hyrax.query_service.find_parents(resource: repo_object).first

      # MorphoSource logic, relies on ArResourceParentship for Valkyrie resources
      repo_object.member_of.first
    end
  end
end
