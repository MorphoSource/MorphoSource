class FundCodeMediaAssociation < ApplicationRecord
  belongs_to :fund_code
  before_save :ensure_active_uniqueness

  def self.destroy_defunct_associations
  	# get all media IDs
  	solr = Morphosource::SolrService.new
  	docs = solr.get_docs(nil, {rows: 999999, fq: ['has_model_ssim:Media'], fl: ['id'] })
  	all_media_ids = docs.pluck('id')

  	all_association_media_ids = all.pluck(:media)
  	defunct_association_media_ids = all_association_media_ids - all_media_ids

  	puts("#{defunct_association_media_ids.count} defunct association media IDs found")

  	verify = defunct_association_media_ids.all? { |m_id| !Media.exists?(m_id) }
  	raise "Issue with destroying defunct assocations" unless verify

  	defunct_association_media_ids.each do |m_id|
	  fcmas = where(media: m_id)
	  puts("#{fcmas.count} defunct associations found for media ID #{m_id}; will destroy them")
	  fcmas.each { |a| a.destroy! }
	end
  end

  private 

  def ensure_active_uniqueness
  	if active?
  		FundCodeMediaAssociation.where(media: media).where.not(id: id).update_all(active: false)
  	end	
  end
end
