module Hyrax
  module Renderers
    class RelatedTaxonomiesRenderer < ShowcaseDefaultAttributeRenderer

      include Hyrax::TaxonomyHelper

      delegate :canonical_taxonomy_object, :trusted_taxonomies, :user_taxonomies, to: :@specimen

      private

        def attribute_value_to_html(value)
          @id = options[:id]
          @specimen = select_specimen(value)
          @markup = ''
          return @markup if (value.blank? || @specimen.taxonomies.length == 1)

          specimen_link = link_to(value, Rails.application.routes.url_helpers.hyrax_biological_specimen_path(select_specimen(value).id, locale: options[:locale]))

          @markup << "<span></span>&nbsp;<span class='showcase-link'>#{specimen_link}</span>"

          create_links(:canonical_taxonomy)
          create_links(:trusted_taxonomies)
          create_links(:user_taxonomies)

          @markup.html_safe
        end

        def create_links(category)
          taxonomies = self.send(category)
          labels = {:canonical_taxonomy => I18n.t('morphosource.taxonomy.labels.canonical'),
                    :trusted_canonical => I18n.t('morphosource.taxonomy.labels.trusted_canonical'),
                    :trusted_taxonomies => I18n.t('morphosource.taxonomy.labels.trusted'),
                    :user_taxonomies => I18n.t('morphosource.taxonomy.labels.user')}

          if taxonomies.present?
            taxonomies.each do |taxonomy|
              next if taxonomy.id == @id

              contributing_user = (category == :user_taxonomies ? contributing_user_link(taxonomy) : '')

              link = link_to(taxonomy.short_title, Rails.application.routes.url_helpers.hyrax_taxonomy_path(taxonomy.id, locale: options[:locale]))

              label = labels[category]
              label = labels[:trusted_canonical] if (category == :canonical_taxonomy && taxonomy.trusted == ["Yes"])

              @markup << "<ul><span>#{label} </span>#{contributing_user}<span class='showcase-link'>#{link}</span></ul>"
            end
          end
        end

        def select_specimen(value)
          @values.select{|specimen| specimen.title.first == value}.first
        end

        def canonical_taxonomy
          Array(canonical_taxonomy_object)
        end

    end
  end
end
