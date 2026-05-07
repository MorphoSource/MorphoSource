# Getty redirects http:// to https:// with a 301; Faraday doesn't follow redirects.
# Reopen the gem class directly so Qa::Authorities::Getty.subauthority_class('tgn')
# returns the patched version rather than an unreachable Morphosource:: subclass.
Qa::Authorities::Getty::TGN.class_eval do
  def build_query_url(q)
    query = ERB::Util.url_encode(sparql(untaint(q)))
    "https://vocab.getty.edu/sparql.json?query=#{query.gsub('&', '%26').gsub(',[%5E,]+,[%5E,]+$', '%2C[^%2C]%2B%2C[^%2C]%2B%24')}&_implicit=false&implicit=true&_equivalent=false&_form=%2Fsparql"
  end

  def find_url(id)
    "https://vocab.getty.edu/download/json?uri=http://vocab.getty.edu/tgn/#{id}.json"
  end

  # Use a regex to exclude the continent and 'world' from the query.
  # If only one word is entered only search the name (not the parent string).
  # If more than one word is entered, one word must appear in the name, and all words in either parent or name.
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
