module Hyrax
  module Actors
    class BiologicalSpecimenActor < Hyrax::Actors::BaseActor

      def create(env)
        env.attributes['title'] = [ generated_title(env) ]
        super
      end

      def update(env)
        env.attributes['title'] = [ generated_title(env) ]
        env.attributes['canonical_taxonomy'] = [ check_canonical_taxonomy(env) ]
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
        
        case
        when inst.present? || coll.present? || cnum.present?
          collection_catalog_generated_title(inst, coll, cnum)
        when attrs['identifier'].present?
          identifier_generated_title(attrs['identifier'])
        when env.curation_concern.depositor.present?
          fallback_generated_title(attrs['vouchered'], ::User.find_by_user_key(env.curation_concern.depositor))
        else
          fallback_generated_title(attrs['vouchered'], env.current_ability.current_user)
        end
      end

      private

      def collection_catalog_generated_title(institution_code='', collection_code='', catalog_number='')
        [institution_code, collection_code, catalog_number].keep_if { |x| x.presence } .join(':')
      end

      def identifier_generated_title(identifier)
        identifier.sort.join(', ')
      end

      def fallback_generated_title(vouchered, user)
        if vouchered.present? && vouchered.first == 'Yes'
          voucher_term = 'Vouchered' 
        else
          voucher_term = 'Unvouchered'
        end
        user_term = user.display_name.present? ? user.display_name : user.email
        I18n.t('morphosource.fallback_object_title', voucher: voucher_term, user: user_term)
      end

      def check_canonical_taxonomy(env)
        canonical_taxonomy = env.attributes["canonical_taxonomy"] || env.curation_concern.canonical_taxonomy
        taxonomy_id = env.attributes["taxonomy_id"] || env.curation_concern.taxonomy_id

        return '' if !canonical_taxonomy.present? || canonical_taxonomy.empty?
        if taxonomy_id.present? && !taxonomy_id.include?(canonical_taxonomy.first)
          return ''
        else
          return canonical_taxonomy.first
        end
      end
    end
  end
end
