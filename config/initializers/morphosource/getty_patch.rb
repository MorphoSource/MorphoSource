# Patches Qa::Authorities::Getty::TGN to use https:// since Getty now returns
# a 301 for http:// requests, which Faraday does not follow. This patches the
# gem class directly because the QA engine's routes handle /authorities/search/getty/tgn
# before MorphoSource's TermsController, so the gem class is what's actually invoked.
#
# Checked qa gem v5.16.0 (latest as of 2026-05-08) — upstream still uses http://.
# TODO: Remove once https://github.com/samvera/questioning_authority is updated to use https.
Rails.application.config.to_prepare do
  Qa::Authorities::Getty::TGN.class_eval do
    def build_query_url(q)
      query = ERB::Util.url_encode(sparql(untaint(q)))
               .gsub('&', '%26')
               .gsub(',[%5E,]+,[%5E,]+$', '%2C[^%2C]%2B%2C[^%2C]%2B%24')
      "https://vocab.getty.edu/sparql.json?query=#{query}&_implicit=false&implicit=true&_equivalent=false&_form=%2Fsparql"
    end

    def find_url(id)
      "https://vocab.getty.edu/download/json?uri=http://vocab.getty.edu/tgn/#{id}.json"
    end
  end
end
