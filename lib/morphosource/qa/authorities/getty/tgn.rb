module Morphosource
  module Qa::Authorities
    class Getty::TGN < ::Qa::Authorities::Getty::TGN

      # Use a regex to exclude the continent and 'world' from the query
      # If only one word is entered only search the name (not the parent string)
      # If more than one word is entered, one word must appear in the name, and all words in either parent or name
      def sparql(q) # rubocop:disable Metrics/MethodLength
        search = untaint(q)
        if search.include?(' ')
          clauses = search.split(' ').collect do |i|
            %((regex(?name, "#{i}", "i") || regex(?alt, "#{i}", "i")))
          end
          ex = "(#{clauses.join(' && ')})"
        else
          ex = %(regex(?name, "#{search}", "i"))
        end
        %(SELECT DISTINCT ?s ?name ?par {
          ?s a skos:Concept; luc:term "#{search}";
              skos:inScheme <http://vocab.getty.edu/tgn/> ;
              gvp:prefLabelGVP [skosxl:literalForm ?name] ;
                    gvp:parentString ?par .
          FILTER #{ex} .
        } ORDER BY ?name ASC(?par)).gsub(/[\s\n]+/, " ")
      end
    end
  end
end
