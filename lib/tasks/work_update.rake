# Rake tasks for updating multiple works (Media, Physical Objects, Taxonomies) on a regular basis

namespace :work_update do
  desc 'Import GBIF Taxonomies for Biological Specimen Objects without GBIF Taxonomies'
  task :import_gbif_taxonomy, [:commit] => :environment do |task, args|
    if args[:commit].present? && args[:commit] == "true"
      commit = true
    else
      commit = false
    end
    Rails.logger.info("commit = #{commit}")

    # todovalk: fix and check this?
    taxonomies = Morphosource::SolrService.new.get_docs("*:*", { fq: ["has_model_ssim:(Taxonomy OR TaxonomyResource)"] })
      .map { |doc| [doc['id'], doc] }.to_h
    bsos = Morphosource::SolrService.new.get_docs("has_model_ssim:BiologicalSpecimen")
      .select { |doc| !doc['gbif_taxonomy_id_ssim'].present? }
    bsos_without_taxonomy = []
    bsos_no_gbif_match = []
    bsos_match_success_existing = []
    bsos_match_success_new = []

    Rails.logger.info("#{bsos.count} biological specimen objects without GBIF taxonomies found")

    bsos.each do |doc|
      # Find best taxonomy to match to
      source_taxonomy_id = doc['canonical_taxonomy_tesim']&.first || doc['taxonomy_id_tesim']&.first
      source_taxonomy = taxonomies[source_taxonomy_id]

      if !source_taxonomy_id.present? || !source_taxonomy.present?
        bsos_without_taxonomy << doc
        next
      end

      # Import GBIF taxonomy match
      gbif_taxonomy_params = Morphosource::GbifSearchService.taxonomy_params_from_gbif_by_terms({
        'taxonomy_kingdom' => source_taxonomy['taxonomy_kingdom_tesim']&.first,
        'taxonomy_phylum' => source_taxonomy['taxonomy_phylum_tesim']&.first,
        'taxonomy_class' => source_taxonomy['taxonomy_class_tesim']&.first,
        'taxonomy_order' => source_taxonomy['taxonomy_order_tesim']&.first,
        'taxonomy_family' => source_taxonomy['taxonomy_family_tesim']&.first,
        'taxonomy_genus' => source_taxonomy['taxonomy_genus_tesim']&.first,
        'taxonomy_species' => source_taxonomy['taxonomy_species_tesim']&.first,
        'taxonomy_subspecies' => source_taxonomy['taxonomy_subspecies_tesim']&.first,
      })

      if !gbif_taxonomy_params.present? || !gbif_taxonomy_params['gbif_key'].present?
        bsos_no_gbif_match << doc
        next
      end

      bso_work = BiologicalSpecimen.find(doc['id'])

      # Find or create GBIF taxonomy
      bso_text = "Biological specimen #{bso_work.id} with source taxonomy #{source_taxonomy['title']}"
      new_gbif_taxonomy_id = nil

      existing_gbif_taxonomy = Morphosource::TaxonomySearchService.call({ gbif_key: gbif_taxonomy_params['gbif_key'] })&.first
      if existing_gbif_taxonomy.present?
        # Associate with existing taxonomy
        Rails.logger.info("#{bso_text} will be matched to existing GBIF taxonomy #{existing_gbif_taxonomy.title&.first} (ID #{existing_gbif_taxonomy.id})")
        bsos_match_success_existing << doc
        new_gbif_taxonomy_id = existing_gbif_taxonomy.id.to_s
      else
        # Create new taxonomy
        Rails.logger.info("#{bso_text} will be matched to new GBIF taxonomy with GBIF key #{gbif_taxonomy_params['gbif_key']}")
        bsos_match_success_new << doc
        if commit
          new_gbif_taxonomy_params = ActionController::Parameters.new({ taxonomy: gbif_taxonomy_params })
          new_gbif_taxonomy_params[:taxonomy].merge!({ visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC })

          new_gbif_taxonomy_id = Morphosource::Action::CreateWorkService.new(
            model: TaxonomyResource,
            params: new_gbif_taxonomy_params,
            user: ::User.batch_user,
            work_attributes_key: :taxonomy
          ).call.value!.id.to_s
        end
      end

      if commit && new_gbif_taxonomy_id.present?
        bso_work.taxonomy_id = (bso_work.taxonomy_id + [new_gbif_taxonomy_id]).uniq
        bso_work.save!
      end
    end

     # TODO report statistics
     Rails.logger.info("Biological specimens finished processing")
     Rails.logger.info("#{bsos_match_success_existing.count} biological specimens were successfully associated with existing GBIF taxonomies")
     Rails.logger.info("#{bsos_match_success_new.count} biological specimens were successfully associated with new GBIF taxonomies")
     Rails.logger.info("#{bsos_without_taxonomy.count} biological specimens have no taxonomy")
     Rails.logger.info("#{bsos_no_gbif_match.count} biological specimens have taxonomy, but could not be matched to a GBIF taxonomy")
     if !commit
      Rails.logger.info("THIS WAS A DRY RUN, NO CHANGES WERE COMMITED")
     end
  end
end