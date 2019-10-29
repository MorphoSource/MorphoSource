module Ms1to2
  class Importer
    attr_accessor :input_path, :media, :ie, :pe, :update, :update_only_if_no_file

    def initialize(input_path, update=false, update_only_if_no_file=true)
      @input_path = input_path
      @update = update
      @update_only_if_no_file = update_only_if_no_file
      # ::Hyrax.config.whitelisted_ingest_dirs = input_path
    end

    def call
      models.each do |m|
        puts(m)
        import_table(m)
      end
      puts("\n\n\n\n\nASSOCIATING WORKS TO COLLECTIONS\n\n\n\n\n")
      coll_models.each do |m|
        puts(m)
        associate_to_collections(m)
      end
    end

    def associate_to_collections(m)
      collection_ids = {}
      CSVParser.new(File.join(input_path, csvfile(m))).each do |attrs|
        if attrs[:id]&.first && attrs[:collection_id]&.first && m.to_s.constantize.exists?(attrs[:id].first)
          collection_ids[attrs[:id].first] = attrs[:collection_id].first
        end
      end
      add_works_to_collections(collection_ids)
    end

    def add_works_to_collections(coll_ids)
      invert_collection_ids(coll_ids).each do |coll_id, work_ids|
        c = Collection.find(coll_id)
        c.reindex_extent = ::Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
        c.add_member_objects work_ids
      end
    end

    def invert_collection_ids(coll_ids)
      coll_ids.each_with_object({}) do |(key, value), out|
        out[value] ||= []
        out[value] << key
      end
    end

    def import_table(m)
      case m
      when :Media
        import_media(m)
      when :Collection
        import_collections(m)
      else
        import_standard(m)
      end
    end

    def import_collections(m)
      # Create collection type
      coll_type = Hyrax::CollectionType.where({:title => 'Project'})&.first
      
      if !coll_type
        puts("Creating collection type")
        coll_type = Hyrax::CollectionType.new(attributes={ :title => 'Project' })
        coll_type.save!
      end

      # Create collections  
      colls = get_table(:Collection)
      colls.each do |collection_id, v|
        if !Collection.exists?(collection_id)
          puts('Creating collection ' + collection_id)
          coll_attrs = {
            :id => collection_id,
            :title => v[:title],
            :depositor => 'julia.m.winchester@gmail.com',
            :visibility => 'open',
            :collection_type => coll_type
          }
          coll = Collection.new(attributes=coll_attrs)
          coll.save!
          puts('Establishing collection permissions')
          ::Hyrax::Collections::PermissionsCreateService.create_default(
            collection: coll, 
            creating_user: User.find_by_user_key('julia.m.winchester@gmail.com'))
        end
      end
    end

    def import_standard(m)
      del_col_ids = ( m == :BiologicalSpecimen ) ? true : false
      csv_importer = ::Importer::CSVImporter.new(
        File.join(input_path, csvfile(m)),
        '', 
        { :depositor => 'julia.m.winchester@gmail.com', :model => m.to_s } )
      csv_importer.import_all(del_col_ids)
    end

    # Special case media methods

    def import_media(m)
      @media = get_table(m)
      @ie = get_table(:ImagingEvent)
      @pe = get_table(:ProcessingEvent)
      combined_table = {}.merge(media).merge(ie).merge(pe)
      
      if combined_table.length == 1
        ids = [combined_table.keys.first]
      else
        ids = ids_in_order
      end

      puts(ids)
      ids.each do |id|
        if combined_table.key?(id)
          # prepare
          attrs = combined_table[id]
          attrs.delete(:collection_id)
          attrs = attrs.merge({ :depositor => 'julia.m.winchester@gmail.com' })
          csv_importer = ::Importer::CSVImporter.new('', input_path, { :model => to_model(id) })

          if !to_model(id).to_s.constantize.exists?(id)
            # create
            csv_importer.import_batch_object(attrs)
          elsif ( update && 
            update_models.include?(to_model(id)) && 
            ( !update_only_if_no_file || !has_original_file?(id, to_model(id)) ) )
            # update
            csv_importer.update_batch_object(attrs)
          end 
        end
      end
    end

    def to_model(id)
      case id[0]
      when 'M'
        :Media
      when 'I'
        :ImagingEvent
      when 'P'
        :ProcessingEvent
      end
    end

    def ids_in_order
      relations = {}
      [media, ie, pe].each do |t|
        t.each { |k, v| relations[k] = v[:parent_id].first }
      end
      sort_order(relations)
    end

    def sort_order(relations)
      relations = relations.clone
      ordered = []
      relations.each do |id, parent_id|
        if ordered.include?(id)
          relations.delete(id)
        elsif parent_id.presence
          if ordered.include?(parent_id)
            # add id after parent_id
            ordered.insert(ordered.index(parent_id)+1, id)
            relations.delete(id)
          elsif relations.include?(parent_id)
            nested_ids = get_nested_ids(id, relations).reverse
            if ordered.include?(nested_ids[0])
              ordered.insert(ordered.index(nested_ids[0])+1, *nested_ids.drop(1))
            else
              ordered = ordered + nested_ids
            end
            relations.delete_if { |v| nested_ids.include?(v) }
          end
        else
          ordered << relations.delete(id)
        end
      end
      ordered
    end

    def get_nested_ids(id, id_array, nested_ids=[])
      nested_ids << id
      if id_array[id].presence
        nested_ids = get_nested_ids(id_array[id], id_array, nested_ids)
      end
      nested_ids
    end

    def get_table(m)
      {}.tap do |t|
        CSVParser.new(File.join(input_path, csvfile(m))).each do |attrs|
          t[attrs[:id].first] = attrs unless attrs[:id].nil?
        end
      end
    end

    def csvfile(m)
      m.to_s.underscore+'.csv'
    end

    def has_original_file?(id, model)
      work = to_model(id).to_s.constantize.find(id)
      return true if ( work.file_sets&.first && 
        work.file_sets&.first.respond_to?(:original_file) && 
        work.file_sets&.first.original_file.presence ) 
      false
    end

    def models
      [:Collection, :Organization, :Device, :Taxonomy, :BiologicalSpecimen, :Media]
    end

    def coll_models
      [:BiologicalSpecimen]
    end

    def update_models
      [:Media]
    end
  end
end