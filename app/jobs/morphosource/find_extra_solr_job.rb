module Morphosource
  class FindExtraSolrJob < Hyrax::ApplicationJob

    queue_as Hyrax.config.update_slow_queue_name

    def perform
      extra_docs = ids.each_with_object([]) do |id, docs|
        begin
          SolrDocument.find(id)
        rescue
          next
        end
        begin
          ActiveFedora::Base.find(id)
        rescue
          docs << id
        end
      end
      File.open("extra_solr_docs.txt", 'w') do |file|
        file.write(text + extra_docs.join(", "))
      end
    end

    def text
      "This file was created by Morphosource::FindExtraSolrJob on #{Date.today.strftime("%Y/%m/%d")}. Fedora was not able to find these ids: "
    end

    def models
       Morphosource::Works::Base.subclasses
    end

    def ids
      Morphosource::SolrService.new.get_docs(nil, fq: ["has_model_ssim:(#{models.join(' OR ')})"], fl: ["id"]).map{ |d| d["id"] }
    end
  end
end
