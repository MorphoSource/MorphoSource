module Ms1to2
  class Ms2OutputData
    def self.standard_tables
      ['media', 'imaging_event', 'processing_event', 'biological_specimen', 
       'taxonomy', 'device', 'organization', 'collection', 'f_to_i']
    end

    attr_accessor *standard_tables, :output_path

    def initialize(output_path)
      standard_tables.each { |t| instance_variable_set "@#{t}", {} }
      @output_path = output_path
    end

    def export_data
      standard_tables.each { |t| export_table(t) }
    end

    def export_table(t)
      return if t == 'f_to_i'
      table = send(t)
      keys = subkeys(table)
      CSV.open(File.join(output_path, t+'.csv'), 'wb') do |csv|
        csv << keys
        table.each do |row_id, row|
          csv << row.values_at(*keys).map { |v| detransform(v) }
        end
      end
    end

    def subkeys(table)
      keys = []
      table.values.map { |v| keys = (keys + v.keys).uniq }
      keys
    end

    def detransform(v)
      Array(v).join(';')
    end

    def exists?(table, id)
      send(table).key?(id)
    end

    def find(table, id, key)
      exists?(table, id) ? send(table)[id][key] : nil
    end

    def find_ids(table, key, value)
      ids = []
      send(table).each do |id, row_hash|
        ids << id if row_hash.key?(key) && row_hash[key] == value
      end
      ids
    end

    def standard_tables
      Ms2OutputData.standard_tables
    end
  end
end