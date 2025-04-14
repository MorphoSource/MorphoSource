module Qa::Authorities
  class FindTaxonomies < Qa::Authorities::FindWorks

    def search(_q, controller)
      # The My::FindWorksSearchBuilder expects a current_user
      return [] unless controller.current_user
      repo = CatalogController.new.blacklight_config.repository
      builder = search_builder(controller)
      response = repo.search(builder)
      docs = response.documents
      docs.map do |doc|
        id = doc.id
        title = doc.title
        taxonomy_domain = doc.taxonomy_domain
        taxonomy_kingdom = doc.taxonomy_kingdom
        taxonomy_phylum = doc.taxonomy_phylum
        taxonomy_superclass = doc.taxonomy_superclass
        taxonomy_class = doc.taxonomy_class
        taxonomy_subclass = doc.taxonomy_subclass
        taxonomy_superorder = doc.taxonomy_superorder
        taxonomy_order = doc.taxonomy_order
        taxonomy_suborder = doc.taxonomy_suborder
        taxonomy_superfamily = doc.taxonomy_superfamily
        taxonomy_family = doc.taxonomy_family
        taxonomy_subfamily = doc.taxonomy_subfamily
        taxonomy_tribe = doc.taxonomy_tribe
        taxonomy_genus = doc.taxonomy_genus
        taxonomy_subgenus = doc.taxonomy_subgenus
        taxonomy_species = doc.taxonomy_species
        taxonomy_subspecies = doc.taxonomy_subspecies
        gbif_key = doc.gbif_key
        depositor = doc.depositor
        { 
          id: id, 
          label: title, 
          value: id, 
          taxonomy_domain: taxonomy_domain, 
          taxonomy_kingdom: taxonomy_kingdom,
          taxonomy_phylum: taxonomy_phylum,
          taxonomy_superclass: taxonomy_superclass,
          taxonomy_class: taxonomy_class,
          taxonomy_subclass: taxonomy_subclass,
          taxonomy_superorder: taxonomy_superorder,
          taxonomy_order: taxonomy_order,
          taxonomy_suborder: taxonomy_suborder,
          taxonomy_superfamily: taxonomy_superfamily,
          taxonomy_family: taxonomy_family,
          taxonomy_subfamily: taxonomy_subfamily,
          taxonomy_tribe: taxonomy_tribe,
          taxonomy_genus: taxonomy_genus,
          taxonomy_subgenus: taxonomy_subgenus,
          taxonomy_species: taxonomy_species,
          taxonomy_subspecies: taxonomy_subspecies,
          gbif_key: gbif_key,
          depositor: depositor
        }
      end
    end

    def search_submission(_q, controller)
      # The My::FindWorksSearchBuilder expects a current_user
      return [] unless controller.current_user
      repo = CatalogController.new.blacklight_config.repository
      builder = search_builder(controller)
      response = repo.search(builder)
      docs = response.documents
      docs.map do |doc|
        id = doc.id
        title = doc.title
        depositor = doc.depositor
        taxonomy_attrs = {
          taxonomy_domain: doc.taxonomy_domain,
          taxonomy_kingdom: doc.taxonomy_kingdom,
          taxonomy_phylum: doc.taxonomy_phylum,
          taxonomy_superclass: doc.taxonomy_superclass,
          taxonomy_class: doc.taxonomy_class,
          taxonomy_subclass: doc.taxonomy_subclass,
          taxonomy_superorder: doc.taxonomy_superorder,
          taxonomy_order: doc.taxonomy_order,
          taxonomy_suborder: doc.taxonomy_suborder,
          taxonomy_superfamily: doc.taxonomy_superfamily,
          taxonomy_family: doc.taxonomy_family,
          taxonomy_subfamily: doc.taxonomy_subfamily,
          taxonomy_tribe: doc.taxonomy_tribe,
          taxonomy_genus: doc.taxonomy_genus,
          taxonomy_subgenus: doc.taxonomy_subgenus,
          taxonomy_species: doc.taxonomy_species,
          taxonomy_subspecies: doc.taxonomy_subspecies,
          gbif_key: doc.gbif_key,
          depositor: depositor,
          depositor_name: User.exists?(depositor) ? User.find(depositor).display_name : nil
        }

        name = build_name(taxonomy_attrs)
        source_info = build_source_info(taxonomy_attrs[:gbif_key], id)
        nice_title = build_title(name, source_info)
        {
          id: id, 
          label: [nice_title], 
          value: id,
          name: name,
          higher_taxonomy: title,
          ms: true,
          gbif_key: taxonomy_attrs[:gbif_key],
          source_info: source_info
        }.merge(taxonomy_attrs)
      end
    end

    private

      def search_builder(controller)
        super
      end

      def ordered_terms
        [ :taxonomy_family, :taxonomy_order, :taxonomy_class,
          :taxonomy_phylum, :taxonomy_kingdom, :taxonomy_domain ]
      end

      def build_name(taxonomy_attrs)
        if taxonomy_attrs[:taxonomy_genus].present?
          build_binomial_name(
            taxonomy_attrs[:taxonomy_genus],
            taxonomy_attrs[:taxonomy_species],
            taxonomy_attrs[:taxonomy_subspecies]
          )
        else
          ordered_terms.each do |t|
            if taxonomy_attrs[t].present?
              return taxonomy_attrs[t].first + ' Indet.'
            end
          end
        end
      end

      def build_binomial_name(genus, species, subspecies)
        "" +
        (genus&.first.present? ? "#{genus&.first}" : '') +
        (species&.first.present? ? " #{species&.first}" : '') +
        (subspecies&.first.present? ? " #{subspecies&.first}" : '')
      end

      def build_source_info(gbif_key, ms_id)
        source_chunks = [];
        source_chunks << 'GBIF Taxonomy' if gbif_key.present?
        source_chunks << 'In MorphoSource' if ms_id.present?
        source_chunks.join(' · ')
      end

      def build_title(name, source_info=nil)
        name +
        ( source_info.present? ? ' · ' + source_info : '' )
      end
  end
end