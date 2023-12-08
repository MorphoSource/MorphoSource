module Morphosource::UserProfile::UserProfileHelper
  include Morphosource::UserProfile::LocationHelper
  include Morphosource::UserProfile::CheckboxValues

  def profile_field_display(field, user)
    case field
    when "state"
      if Morphosource::UserProfile::LocationHelper::STATE[user.country]&.key(user.state) 
        return Morphosource::UserProfile::LocationHelper::STATE[user.country].key(user.state) 
      else
        return user.state
      end
    when "country"
      return Morphosource::UserProfile::LocationHelper::COUNTRY.key(user.country)
    when "orcid"
      return link_to user.orcid, user.orcid, { target: '_blank' }
    when "twitter_handle"
      return link_to user.twitter_handle, "//twitter.com/#{user.twitter_handle}", {target:'_blank'}
    when "facebook_handle"
      return link_to user.facebook_handle, "//facebook.com/#{user.facebook_handle}", {target:'_blank'} 
    when "website"
      unless user.website.match?(/\Ahttps?:\/\//i)
        website = "//#{user.website}"
      else
        website = user.website
      end
      return link_to user.website, website, { target:'_blank'}
    else
      if (val = user.send(field)).is_a?(Array) 
        return val.reject!(&:empty?)&.join(", ") 
      else
        return val
      end
    end
  end

end
