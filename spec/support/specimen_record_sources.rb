# Keep specs on the default sources regardless of a developer's local SPECIMEN_RECORD_SOURCES
RSpec.configure do |config|
  config.before do
    Hyrax.config.specimen_record_sources = [:idigbio]
  end
end
