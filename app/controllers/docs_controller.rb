class DocsController < ApplicationController
  layout 'homepage'

  def about
    @renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    @markdown_path = Rails.root.join("app", "assets", "markdown", "about.md")
  end

  def contributor_terms
  end

  def terms
  end

  private

    def outdated_flash
      flash[:notice] = outdated_flash_msg
    end

    def outdated_flash_msg
      'This page may be outdated. Information here may not be applicable to the current version of MorphoSource. The page will be updated soon.'
    end
end
