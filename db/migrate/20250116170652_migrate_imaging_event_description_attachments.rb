class MigrateImagingEventDescriptionAttachments < ActiveRecord::Migration[5.2]
  def up
    Rake::Task.clear
    Rails.application.load_tasks
    Rake::Task["morphosource:migrate_attachments[ImagingEvent,description_attachment,ie_description,migrate]"].invoke
  end

  def down
    Rake::Task.clear
    Rails.application.load_tasks
    Rake::Task["morphosource:rollback_migrate_attachments[ImagingEvent,description_attachment,ie_description]"].invoke
  end
end
