module Morphosource::CollectionRolesHelper

  def ms_access_options
     options_for_select(access_array)
  end

  def ms_edit_access_options(access)
    options = access_array.select{|option| !option.include? access}
    options_for_select(options << ['Remove', 'remove'])
  end

  def collection_options
    collections = @current_user.collections_managed
    collections.delete(@collection)
    options_for_select(collections.map{|c| [c.title.first, c.id]})
  end

  def access_array
    [[t('.manager'), 'managers'], [t('.depositor'), 'depositors'], [t('.viewer'), 'viewers']]
  end

end
