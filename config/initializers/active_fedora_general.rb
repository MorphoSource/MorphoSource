# Monkey-patch to short circuit ActiveModel::Dirty which attempts to load the whole master files ordered list when calling nodes_will_change!
# This leads to a stack level too deep exception when attempting to delete a master file from a media object on the manage files step.
# See https://github.com/samvera/active_fedora/pull/1312/commits/7c8bbbefdacefd655a2ca653f5950c991e1dc999#diff-28356c4daa0d55cbaf97e4269869f510R100-R103
# MorphoSource is using this monkey-patch in response to a bug where adding a child to a work with too many other children causes a similar stack level too deep error
ActiveFedora::Aggregation::ListSource.class_eval do
  def attribute_will_change!(attr)
    return super unless attr == 'nodes'
    attributes_changed_by_setter[:nodes] = true
  end
end

# overriding MAX_ROWS definition here: https://github.com/samvera/active_fedora/blob/a66a7e9618c101e6d06d0f77e36cc5a2c28b8d89/lib/active_fedora/solr_service.rb#L8
# Fixes bug where unable to remove media from large collections
class ActiveFedora::SolrService
  MAX_ROWS = 50_000
end

# Monkey-patch to change count to use post instead of get, avoiding solr URI too long errors
ActiveFedora::SolrService.class_eval do
  # Get the count of records that match the query
  # @param [String] query a solr query
  # @param [Hash] args arguments to pass through to `args' param of SolrService.query (note that :rows will be overwritten to 0)
  # @return [Integer] number of records matching
  def count(query, args = {})
    args = args.merge(rows: 0)
    SolrService.post(query, args)['response']['numFound'].to_i
  end
end