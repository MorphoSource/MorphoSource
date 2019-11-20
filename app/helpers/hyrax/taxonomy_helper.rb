module Hyrax::TaxonomyHelper

  def contributing_user_link(taxonomy, is_label = true)
    user = taxonomy.contributing_user
    if user.present?
      display_email = user.email.dup
      colon_string = (is_label == true ? ': ' : '')
      link_to((user.display_name || display_email).concat(colon_string), Hyrax::Engine.routes.url_helpers.user_path(user), {:class => "contributing-user"})
    else
      ""
    end
  end

end
