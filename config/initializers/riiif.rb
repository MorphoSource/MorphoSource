Riiif::Image.file_resolver = Riiif::HTTPFileResolver.new
Riiif::Image.info_service = lambda do |id, _file|
  # id will look like a path to a pcdm:file
  # (e.g. rv042t299%2Ffiles%2F6d71677a-4f80-42f1-ae58-ed1063fd79c7)
  # but we just want the id for the FileSet it's attached to.

  # Capture everything before the first slash
  fs_id = id.sub(/\A([^\/]*)\/.*/, '\1')
  resp = ActiveFedora::SolrService.get("id:#{fs_id}")
  doc = resp['response']['docs'].first
  raise "Unable to find solr document with id:#{fs_id}" unless doc
  { height: doc['height_is'], width: doc['width_is'] }
end

Riiif::Image.file_resolver.id_to_uri = lambda do |id|
  # ActiveFedora::Base.id_to_uri(CGI.unescape(id)).tap do |url|
  #   Rails.logger.info "Riiif resolved #{id} to #{url}"
  # end
  byebug
  item_id = FileSet.find(id.sub(/\A([^\/]*)\/.*/, '\1')).in_works.first.identifier.first

  "https://images.slide-atlas.org/api/v1/item/#{item_id}/tiles/region?units=base_pixels&width=3000&exact=false&encoding=JPEG&jpegQuality=100&jpegSubsampling=0"
end

Riiif::Image.authorization_service = Hyrax::IIIFAuthorizationService

Riiif.not_found_image = Rails.root.join('app', 'assets', 'images', 'us_404.svg')
Riiif.unauthorized_image = Rails.root.join('app', 'assets', 'images', 'us_404.svg')

Riiif::Engine.config.cache_duration_in_days = 365
