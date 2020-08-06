module Morphosource
  class TagsController < ApplicationController
    helper TagsHelper

    def index
      response = Morphosource::SolrService.new.search_terms("keyword_tesim", params[:uq])
      @tags = response["terms"]["keyword_tesim"]
    end

    def show
      @response = TaggedMediaSearchService.call(scope: self)
      @documents = @response["response"]["docs"].map{|doc| SolrDocument.new(doc) }
      @document_count = @response[:response][:numFound]
      render 'morphosource/tags/show'
    end
  end
end
