module Morphosource
  module Qa::Authorities
    class Getty::AAT < ::Qa::Authorities::Getty::AAT

      # Getty redirects http:// to https:// with a 301; Faraday doesn't follow redirects.
      def build_query_url(q)
        "https://vocab.getty.edu/sparql.json?query=#{ERB::Util.url_encode(sparql(q))}&_implicit=false&implicit=true&_equivalent=false&_form=%2Fsparql"
      end

      def find_url(id)
        "https://vocab.getty.edu/download/json?uri=http://vocab.getty.edu/aat/#{id}.json"
      end

      def sparql(q) # rubocop:disable Metrics/MethodLength
        # if @facet_id hasn't been set, use the top of the aat hierarchy
        @facet_id ||= 300000000
        search = untaint(q)
        if search.include?(' ')
          clauses = search.split(' ').collect do |i|
            %((regex(?name, "#{i}", "i")))
          end
          ex = "(#{clauses.join(' && ')})"
        else
          ex = %(regex(?name, "#{search}", "i"))
        end
        # The full text index matches on fields besides the term, so we filter to ensure the match is in the term.
        %(SELECT ?s ?name {
                ?s a skos:Concept;
                   gvp:broaderExtended aat:#{@facet_id};
                   skos:inScheme <http://vocab.getty.edu/aat/> ;
                   gvp:prefLabelGVP [skosxl:literalForm ?name];
                   luc:term "#{search}";.
                FILTER #{ex} .
              } ORDER BY ?name).gsub(/[\s\n]+/, " ")
      end
    end
  end
end
