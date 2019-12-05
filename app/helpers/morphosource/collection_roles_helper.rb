module Morphosource::CollectionRolesHelper

  def ms_access_options
     options_for_select([[t('.manager'), 'managers'], [t('.depositor'), 'depositors'], [t('.viewer'), 'viewers']])
  end

  def collection_options
    collections = @current_user.collections_managed
    collections.delete(@collection)
    options_for_select(collections.map{|c| [c.title.first, c.id]})
  end

end
