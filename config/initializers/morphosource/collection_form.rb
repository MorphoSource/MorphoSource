# breaks unless require hyrax/search_state - should be fixed in Hyrax 3.0: https://github.com/samvera/hyrax/pull/3686
require 'hyrax/search_state'
Hyrax::Forms::CollectionForm.class_eval do

  self.terms = [:title,
                :creator,
                :contributor,
                :description,
                :keyword,
                :representative_id,
                :thumbnail_id,
                :based_near,
                :related_url,
                :visibility,
                :collection_type_gid]

  self.required_fields = [:title]

  # Terms that appear above the accordion
  def primary_terms
    [:title, :description]
  end

  # Terms that appear within the accordion
  def secondary_terms
    [:creator,
     :contributor,
     :keyword,
     :based_near,
     :related_url]
  end


end
