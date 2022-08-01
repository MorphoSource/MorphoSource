module Hyrax
  module Actors
    class CulturalHeritageObjectActor < Hyrax::Actors::BaseActor
      include Morphosource::LinkedTeams::LinkedTeamsManagement

      def create(env)
        env.attributes['title'] = [ generated_title(env) ]
        add_team_access(env)
        super
      end

      def update(env)
        env.attributes['title'] = [ generated_title(env) ]
        super
      end

      def generated_title(env)
        attrs = env.attributes

        if attrs.key?('institution_code')
          inst = attrs['institution_code']&.first.presence || ''
        else
          inst = env.curation_concern.institution_code&.first.presence || ''
        end

        if attrs.key?('collection_code')
          coll = attrs['collection_code']&.first.presence || ''
        else
          coll = env.curation_concern.collection_code&.first.presence || ''
        end

        if attrs.key?('catalog_number')
          cnum = attrs['catalog_number']&.first.presence || ''
        else
          cnum = env.curation_concern.catalog_number&.first.presence || ''
        end

        if attrs.key?('short_title')
          titl = attrs['short_title']&.first.presence || ''
        else
          titl = env.curation_concern.short_title&.first.presence || ''
        end

        title = preferred_generated_title(inst, coll, cnum, titl)
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

      def add_team_access(env)
        return unless env.attributes[:organization_id] && env.attributes[:organization_id].present?
        add_organization_team_access_for_po(env)
      end

      def preferred_generated_title(institution_code, collection_code, catalog_number, short_title)
        [
          [institution_code, collection_code, catalog_number].keep_if { |x| x.presence } .join(':').presence,
          ( short_title.present? ? short_title.titleize : "" ).presence
        ].compact.join(' ')
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
