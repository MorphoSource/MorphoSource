module Morphosource
  module Qa
    module Authorities
      module Getty
        class TGN < ::Qa::Authorities::Getty::TGN
          SPARQL_ENDPOINT = "https://vocab.getty.edu/sparql.json"
          SPARQL_PARAMS = "_implicit=false&implicit=true&_equivalent=false&_form=%2Fsparql"
          PARENT_EXCLUSION_PATTERN = ',[%5E,]+,[%5E,]+$'
          PARENT_EXCLUSION_REPLACEMENT = '%2C[^%2C]%2B%2C[^%2C]%2B%24'

          def build_query_url(q)
            query = ERB::Util.url_encode(sparql(untaint(q)))
                     .gsub('&', '%26')
                     .gsub(PARENT_EXCLUSION_PATTERN, PARENT_EXCLUSION_REPLACEMENT)
            "#{SPARQL_ENDPOINT}?query=#{query}&#{SPARQL_PARAMS}"
          end

          def find_url(id)
            "https://vocab.getty.edu/download/json?uri=http://vocab.getty.edu/tgn/#{id}.json"
          end
        end
      end
    end
  end
end
