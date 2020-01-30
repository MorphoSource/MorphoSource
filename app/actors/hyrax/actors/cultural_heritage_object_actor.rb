module Hyrax
  module Actors
    class CulturalHeritageObjectActor < Hyrax::Actors::BaseActor

      def create(env)
        env.attributes['title'] = [ generated_title(env) ]
        super
      end

      def update(env)
        env.attributes['title'] = [ generated_title(env) ]
        super
      end

      def generated_title(env)
        attrs = env.attributes
        title = preferred_generated_title(attrs['institution_code'], attrs['collection_code'], attrs['catalog_number'], attrs['short_title'])
        return title unless title.empty?
        title = identifier_generated_title(attrs['identifier'])
        return title unless title.empty?
        if env.curation_concern.depositor.present?
          fallback_generated_title(attrs['vouchered'], ::User.find_by_user_key(env.curation_concern.depositor))
        else
          fallback_generated_title(attrs['vouchered'], env.current_ability.current_user)
        end
      end

      private

      def preferred_generated_title(institution_code, collection_code, catalog_number, short_title)
        [institution_code, collection_code, catalog_number, short_title].flatten.join(':')
      end

      def identifier_generated_title(identifier)
        identifier.sort.join(', ')
      end

      def fallback_generated_title(vouchered, user)
        voucher_term = vouchered.first == 'Yes' ? 'Vouchered' : 'Unvouchered'
        user_term = user.display_name.present? ? user.display_name : user.user_key
        I18n.t('morphosource.fallback_object_title', voucher: voucher_term, user: user_term)
      end

    end
  end
end
